package org.tbyrne.display.controls
{
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.containers.ISelectableRenderer;
	import org.tbyrne.display.tabFocus.ITabFocusable;
	import org.tbyrne.display.tabFocus.InteractiveAssetFocusWrapper;
	
	use namespace DisplayNamespace;
	
	public class ToggleButton extends Button implements ISelectableRenderer
	{
		DisplayNamespace static var STATE_UNSELECTABLE:String = "unselectable";
		DisplayNamespace static var STATE_SELECTED:String = "selected";
		DisplayNamespace static var STATE_UNSELECTED:String = "unselected";
		
		public function get selected():Boolean{
			return _selected;
		}
		public function set selected(value:Boolean):void{
			if(_booleanConsumer && useDataForSelected){
				_ignoreDataChanges = true;
				_booleanConsumer.booleanValue = value;
				value = _booleanProvider.booleanValue;
				_ignoreDataChanges = false;
			}
			if(_selected!=value){
				_selected = value;
				assessSelectedState();
				if(_selectedChanged)_selectedChanged.perform(this);
			}
		}
		
		public function get tabFocusable(): ITabFocusable{
			attemptInit();
			return _tabFocusable;
		}
		
		override public function set data(value:IControlData):void{
			if(super.data!=value){
				super.data = value;
			}else if(!_booleanProvider && _data){
				/*
				If a list's dataProvider array is reset and some items
				in the array are the same we still want to reset their
				selected property.
				*/
				selected = false;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get selectedChanged():IAct{
			if(!_selectedChanged)_selectedChanged = new Act();
			return _selectedChanged;
		}
		
		protected var _selectedChanged:Act;
		
		/**
		 * Whether the selected property of the data should be used to get/set
		 * the state of the ToggleButton. Only changes behaviour if the data
		 * implements IBooleanConsumer.
		 */
		DisplayNamespace function get useDataForSelected():Boolean{
			return _useDataForSelected;
		}
		DisplayNamespace function set useDataForSelected(value:Boolean):void{
			if(_useDataForSelected!=value){
				_useDataForSelected = value;
				if(value){
					// this will force the data to conform (if possible)
					selected = selected;
				}else if(_booleanProvider){
					selected = _booleanProvider.booleanValue;
				}
			}
		}
		
		private var _useDataForSelected:Boolean = true;
		
		private var _booleanProvider:IBooleanProvider;
		private var _booleanConsumer:IBooleanConsumer;
		protected var _selected:Boolean;
		private var _tabFocusable:InteractiveAssetFocusWrapper;
		private var _ignoreDataChanges:Boolean;
		
		protected var _selectedState:StateDef = new StateDef([STATE_UNSELECTABLE,STATE_SELECTED,STATE_UNSELECTED],0);
		
		public function ToggleButton(asset:IDisplayObject=null){
			super(asset);
		}
		override public function setSize(width:Number, height:Number):void{
			super.setSize(width, height);
		} 
		override protected function init() : void{
			super.init();
			_tabFocusable = new InteractiveAssetFocusWrapper(_interactiveObjectAsset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_tabFocusable.interactiveAsset = _interactiveArea;
		}
		override protected function unbindFromAsset() : void{
			_tabFocusable.interactiveAsset = null;
			super.unbindFromAsset();
		}
		private function onProviderChanged(from:IBooleanProvider):void{
			if(useDataForSelected && !_ignoreDataChanges)this.selected = from.booleanValue;
			assessSelectedState();
		}
		protected function assessSelectedState():void{
			if(!_booleanProvider){
				_selectedState.selection = 0;
			}else{
				_selectedState.selection = _booleanProvider.booleanValue?1:2;
			}
		}
		override protected function acceptClick():void{
			selected = !selected;
			if(!useDataForSelected && _booleanConsumer){
				_booleanConsumer.booleanValue = !_booleanProvider.booleanValue;
			}
			super.acceptClick();
		}
		
		
		override protected function fillStateList(fill:Array):Array{
			fill.push(_selectedState);
			fill = super.fillStateList(fill);
			return fill;
		}
		override protected function clearData():void{
			super.clearData();
			if(_booleanProvider){
				_booleanProvider.booleanValueChanged.removeHandler(onProviderChanged);
				_booleanProvider = null;
				_booleanConsumer = null;
				if(useDataForSelected){
					selected = false;
				}
			}
		}
		
		override protected function assessData():void{
			super.assessData();
			if(_data.selected){
				_booleanProvider = _data.selected;
				_booleanConsumer = (_booleanProvider as IBooleanConsumer);
				if(useDataForSelected){
					selected = _booleanProvider.booleanValue;
				}
				_booleanProvider.booleanValueChanged.addHandler(onProviderChanged);
				assessSelectedState();
			}
		}
	}
}