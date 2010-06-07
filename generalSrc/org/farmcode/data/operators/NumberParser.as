package org.farmcode.data.operators
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.INumberConsumer;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	
	public class NumberParser implements IStringConsumer, IStringProvider
	{
		public function get value():*{
			return stringValue;
		}
		public function get stringValue():String{
			return _numberProvider?String(_numberProvider.numericalValue):null;
		}
		public function set stringValue(value:String):void{
			if(_numberConsumer)_numberConsumer.numericalValue = parseFloat(value);
		}
		
		public function get numberProvider():INumberProvider{
			return _numberProvider;
		}
		public function set numberProvider(value:INumberProvider):void{
			if(_numberProvider != value){
				if(_numberProvider){
					_numberProvider.numericalValueChanged.removeHandler(onNumberChanged);
				}
				_numberProvider = value;
				_numberConsumer = (value as INumberConsumer);
				if(_numberProvider){
					_numberProvider.numericalValueChanged.addHandler(onNumberChanged);
				}
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return stringValueChanged;
		}
		
		protected var _stringValueChanged:Act;
		private var _numberProvider:INumberProvider;
		private var _numberConsumer:INumberConsumer;
		
		protected function onNumberChanged(from:INumberProvider):void{
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
	}
}