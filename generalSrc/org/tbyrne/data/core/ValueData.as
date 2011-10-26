package org.tbyrne.data.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IValueProvider;
	
	public class ValueData implements IValueProvider
	{
		
		public function get value():*{
			return _value;
		}
		public function set value(value:*):void{
			if(_value!=value){
				_value = value;
				if(_valueChanged)_valueChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get valueChanged():IAct{
			return (_valueChanged || (_valueChanged = new Act()));
		}
		
		protected var _valueChanged:Act;
		protected var _value:*;
		
		
		public function ValueData(value:*=null){
			this.value = value;
		}
	}
}