package org.tbyrne.debug.data.core
{
	import flash.display.BitmapData;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.data.dataTypes.IBitmapDataProvider;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.IDataProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.data.operators.StringProxy;
	import org.tbyrne.debug.data.coreTypes.ILayoutViewProvider;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.ILayoutView;
	
	public class DebugData extends StringProxy implements IBooleanConsumer, IBooleanProvider, IDataProvider, IBitmapDataProvider, ITriggerableAction, ILayoutViewProvider
	{
		public function get layoutView():ILayoutView{
			return _layoutView;
		}
		public function set layoutView(value:ILayoutView):void{
			if(_layoutView!=value){
				_layoutView = value;
				if(_layoutViewChanged)_layoutViewChanged.perform(this);
			}
		}
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(_intBooleanValue!=value){
				_intBooleanValue = value;
				checkSelected();
			}
		}
		
		public function get bitmapData():BitmapData{
			if(_bitmapProvider)return _bitmapProvider.bitmapData;
			else return null;
		}
		
		public function get bitmapProvider():IBitmapDataProvider{
			return _bitmapProvider;
		}
		public function set bitmapProvider(value:IBitmapDataProvider):void{
			if(_bitmapProvider!=value){
				if(_bitmapProvider){
					_bitmapProvider.bitmapDataChanged.removeHandler(onBitmapChanged);
				}
				_bitmapProvider = value;
				if(_bitmapProvider){
					_bitmapProvider.bitmapDataChanged.addHandler(onBitmapChanged);
				}
				if(_bitmapDataChanged)_bitmapDataChanged.perform(this);
			}
		}
		
		public function get data():*{
			if(_childData && _childData.length){
				return _childData;
			}else{
				return null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			if(!_booleanValueChanged)_booleanValueChanged = new Act();
			return _booleanValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get bitmapDataChanged():IAct{
			if(!_bitmapDataChanged)_bitmapDataChanged = new Act();
			return _bitmapDataChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get layoutViewChanged():IAct{
			if(!_layoutViewChanged)_layoutViewChanged = new Act();
			return _layoutViewChanged;
		}
		
		public function get selectData():ITriggerableAction{
			return _selectData;
		}
		public function set selectData(value:ITriggerableAction):void{
			if(_selectData!=value){
				_selectData = value;
				checkSelected();
			}
		}
		
		private var _layoutView:ILayoutView;
		private var _selectData:ITriggerableAction;
		private var _bitmapProvider:IBitmapDataProvider;
		protected var _booleanValueChanged:Act;
		protected var _bitmapDataChanged:Act;
		protected var _layoutViewChanged:Act;
		private var _childData:LinkedList;
		
		private var _intBooleanValue:Boolean;
		private var _booleanValue:Boolean;
		
		public function DebugData(stringProvider:IStringProvider=null, selectData:ITriggerableAction=null){
			super(stringProvider);
			this.selectData = selectData;
		}
		protected function onBitmapChanged():void{
			if(_bitmapDataChanged)_bitmapDataChanged.perform(this);
		}
		public function addChildData(data:IStringProvider):void{
			if(!_childData){
				_childData = new LinkedList();
			}
			_childData.push(data);
			checkSelected();
		}
		public function removeChildData(data:IStringProvider):void{
			if(_childData){
				_childData.removeFirst(data);
			}
		}
		protected function checkSelected():void{
			var value:Boolean = (isTogglable() && _intBooleanValue);
			if(_booleanValue != value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
			}
		}
		public function triggerAction(scopeDisplay:IDisplayObject):void{
			if(_selectData)_selectData.triggerAction(scopeDisplay);
		}
		protected function isTogglable():Boolean{
			return (_childData && _childData.length)
		}
		public function toString():String{
			return "[DebugData: "+stringValue+"]";
		}
	}
}