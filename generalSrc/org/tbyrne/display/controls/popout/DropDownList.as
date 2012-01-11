package org.tbyrne.display.controls.popout {
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.AssetNames;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.containers.ListBox;
	import org.tbyrne.display.controls.TextLabelButton;
	import org.tbyrne.display.layout.ILayoutSubject;
	
	use namespace DisplayNamespace;
	
	public class DropDownList extends PopoutList {
		public function set selectedIndex(value: int):void{
			if(_selectedIndex!=value){
				if(value==-1){
					_listBox.selectedIndices = [];
				}else{
					_listBox.selectedIndices = [value];
				}
				assessSelected();
			}
		}
		public function get selectedIndex() : int{
			return _selectedIndex;
		}
		public function get selectedData() : *{
			return _selectedData;
		}
		
		public function get dataProvider():*{
			return _listBox.dataProvider;
		}
		public function set dataProvider(value:*):void{
			if(_listBox.dataProvider != value){
				_selectedIndex = -1;
				_selectedData = null;
				_listBox.dataProvider = value;
				assessSelected();
			}
		}
		public function get validateSelectionCount():Boolean{
			return _validateSelectionCount;
		}
		public function set validateSelectionCount(value:Boolean):void{
			if(_validateSelectionCount!=value){
				_validateSelectionCount = value;
				if(value){
					_listBox.maxSelected = 1;
					_listBox.minSelected = 0;
				}else{
					_listBox.maxSelected = NaN;
					_listBox.minSelected = NaN;
				}
			}
		}
		
		
		public function get prompt():String{
			return _prompt;
		}
		public function set prompt(value:String):void{
			if(_prompt!=value){
				_prompt = value;
				assessSelected();
			}
		}
		
		/**
		 * handler(dropDownList:DropDownList, selectedIndex:int, selectedData:*)
		 */
		public function get selectionChangeAct() : IAct{
			return _selectionChangeAct;
		}
		
		private var _validateSelectionCount:Boolean = true;
		private var _prompt:String;
		private var _selectedIndex:int=-2; // -1 is unselected (initially -2 so that -1 is seen as a change)
		private var _selectedData:*;
		private var _textLabelButton:TextLabelButton;
		private var _proxyStringProvider:ProxyStringProvider;
		
		private var _selectionChangeAct:Act = new Act(); 
		
		public function DropDownList(asset:IDisplayObject=null) {
			super(asset);
			_textLabelButton=new TextLabelButton();
			_textLabelButton.useDataForSelected = false;
			_textLabelButton.measurementsChanged.addHandler(onTextMeasureChange);
			_textLabelButton.clicked.addHandler(onButtonClicked);
			_listBox.selectionChangeAct.addHandler(onListSelect);
			
			_proxyStringProvider = new ProxyStringProvider();
			_textLabelButton.data = _proxyStringProvider;
		}
		protected function onListSelect(list:ListBox, selectedIndices:Array, selectedData:Dictionary):void {
			assessSelected();
			_popoutDisplay.popoutShown = false;
		}
		override protected function onPopoutOpen(popoutDisplay:PopoutDisplay, popout:ListBox):void {
			super.onPopoutOpen(popoutDisplay, popout);
			_textLabelButton.selected = true;
		}
		override protected function onPopoutClose(popoutDisplay:PopoutDisplay, popout:ListBox):void {
			super.onPopoutClose(popoutDisplay, popout);
			_textLabelButton.selected = false;
		}
		
		override protected function bindToAsset():void {
			super.bindToAsset();
			_textLabelButton.asset=asset;
		}
		
		override protected function unbindFromAsset():void {
			super.unbindFromAsset();
			_textLabelButton.asset=null;
		}
		override public function setAssetAndPosition(asset:IDisplayObject):void{
			this.asset = asset;
			if(asset){
				//checkIsBound();
				
				// this avoids the list item asset affecting the position/size
				var boundsAsset:IDisplayObject = _containerAsset.takeAssetByName(AssetNames.BACKING,true);
				if(!boundsAsset){
					boundsAsset = asset;
				}
				setPosition(asset.x,asset.y);
				setSize(boundsAsset.naturalWidth,boundsAsset.naturalHeight);
				asset.scaleX = 1;
				asset.scaleY = 1;
			}
		}
		
		override public function setPosition(x:Number, y:Number) : void{
			super.setPosition(x,y);
			_textLabelButton.setPosition(x,y);
		}
		override public function setSize(width:Number, height:Number) : void{
			super.setSize(width,height);
			_textLabelButton.setSize(width,height);
		}
		protected function onButtonClicked(from:TextLabelButton):void {
			_popoutDisplay.popoutShown = _textLabelButton.selected;
		}
		protected function onTextMeasureChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			invalidateMeasurements();
		}
		override protected function closeOnClickOutside():Boolean{
			return true;
		}
		protected function assessSelected():void{
			var newIndex:int = (_listBox.selectedIndices.length?_listBox.selectedIndices[0]:-1);
			if(newIndex!=_selectedIndex){
				_selectedIndex = newIndex;
				if(_selectedIndex==-1){
					_selectedData = null;
					_proxyStringProvider.data = prompt;
				}else{
					_selectedData = _listBox.selectedData[_selectedIndex];
					_proxyStringProvider.data = _selectedData;
				}
				_selectionChangeAct.perform(this,_selectedIndex,_selectedData);
			}
		}
	}
}
import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import org.tbyrne.data.dataTypes.IStringProvider;

class ProxyStringProvider implements IStringProvider{
	
	/**
	 * @inheritDoc
	 */
	public function get valueChanged():IAct{
		return stringValueChanged;
	}
	/**
	 * @inheritDoc
	 */
	public function get stringValueChanged():IAct{
		return ((_stringValueChanged) || (_stringValueChanged = new Act()));
	}
	
	protected var _stringValueChanged:Act;
	
	
	public function get value():*{
		return _stringValue;
	}
	public function get stringValue():String{
		return _stringValue;
	}
	
	
	
	public function get data():*{
		return _stringProvider;
	}
	public function set data(value:*):void{
		if(_stringProvider!=value){
			if(_stringProvider){
				_stringProvider.stringValueChanged.removeHandler(onStringProvChanged);
			}
			_data = value;
			_stringProvider = value as IStringProvider;
			if(_stringProvider){
				setStringValue(_stringProvider.stringValue);
				_stringProvider.stringValueChanged.addHandler(onStringProvChanged);
			}else if(_data!=null){
				setStringValue(String(_data));
			}else{
				setStringValue(null);
			}
		}
	}
	
	
	private var _data:*;
	private var _stringProvider:IStringProvider;
	private var _stringValue:String;
	
	private function setStringValue(value:String):void{
		if(_stringValue!=value){
			_stringValue = value;
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
	}
	private function onStringProvChanged(from:IStringProvider):void{
		setStringValue(_stringProvider.stringValue);
	}
		
}