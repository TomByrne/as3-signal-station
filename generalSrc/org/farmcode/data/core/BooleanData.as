package org.farmcode.data.core
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.data.dataTypes.IValueProvider;
	
	public class BooleanData implements IBooleanConsumer, IBooleanProvider, IValueProvider
	{
		
		public function get value():*{
			return _booleanValue;
		}
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
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
		public function get valueChanged():IAct{
			return booleanValueChanged;
		}
		
		protected var _booleanValueChanged:Act;
		private var _booleanValue:Boolean;
		
		public function BooleanData(){
		}
	}
}