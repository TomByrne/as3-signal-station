package org.farmcode.debug.data.core
{
	import flash.display.BitmapData;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.collections.linkedList.LinkedList;
	import org.farmcode.data.dataTypes.IBitmapProvider;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.data.dataTypes.IDataProvider;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.operators.StringProxy;
	
	public class DebugData extends StringProxy implements IBooleanConsumer, IBooleanProvider, IDataProvider, IBitmapProvider
	{
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
			}
		}
		
		public function get bitmapData():BitmapData{
			return _bitmapData;
		}
		public function set bitmapData(value:BitmapData):void{
			if(_bitmapData!=value){
				_bitmapData = value;
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
		
		private var _bitmapData:BitmapData;
		protected var _booleanValueChanged:Act;
		protected var _bitmapDataChanged:Act;
		private var _booleanValue:Boolean;
		private var _childData:LinkedList;
		
		public function DebugData(stringProvider:IStringProvider=null, bitmapData:BitmapData=null){
			super(stringProvider);
			this.bitmapData = bitmapData;
		}
		public function addChildData(data:DebugData):void{
			if(!_childData){
				_childData = new LinkedList();
			}
			_childData.push(data);
		}
	}
}