package org.tbyrne.data.operators
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.INumberConsumer;
	import org.tbyrne.data.dataTypes.INumberProvider;

	public class NumberProxy implements INumberConsumer, INumberProvider
	{
		public function get numericalValue():Number{
			return _validatedValue;
		}
		public function set numericalValue(value:Number):void{
			if(_numericalValue!=value){
				_numericalValue = value;
				checkValue();
			}
		}
		public function get numberProvider():INumberProvider{
			return _numberProvider;
		}
		public function set numberProvider(value:INumberProvider):void{
			if(_numberProvider!=value){
				if(_numberProvider){
					_numberProvider.numericalValueChanged.removeHandler(onProviderChanged);
				}
				_numberProvider = value;
				_numberConsumer = (value as INumberConsumer);
				if(_numberProvider){
					_numberProvider.numericalValueChanged.addHandler(onProviderChanged);
					numericalValue = _numberProvider.value;
				}else{
					numericalValue = NaN;
				}
			}
		}
		public function get stringValue():String{
			return _stringValue;
		}
		
		public function get value():*{
			return numericalValue;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return numericalValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get numericalValueChanged():IAct{
			if(!_numericalValueChanged)_numericalValueChanged = new Act();
			return _numericalValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		
		protected var _stringValueChanged:Act;
		protected var _numericalValueChanged:Act;
		
		private var _numericalValue:Number;
		private var _validatedValue:Number;
		private var _stringValue:String;
		private var _numberProvider:INumberProvider;
		private var _numberConsumer:INumberConsumer;
		private var _ignoreProviderChanges:Boolean;
		
		public function NumberProxy(numberProvider:INumberProvider=null){
			this.numberProvider = numberProvider;
		}
		protected function onProviderChanged(from:INumberProvider):void{
			if(!_ignoreProviderChanges)numericalValue = _numberProvider.numericalValue;
		}
		protected function checkValue():void{
			var newVal:Number = validateValue(_numericalValue);
			if(_validatedValue!=newVal && !(isNaN(value) && isNaN(_numericalValue))){
				var oldStr:String = _stringValue;
				if(_numberConsumer){
					_ignoreProviderChanges = true;
					_numberConsumer.numericalValue = newVal;
					newVal = _numberProvider.numericalValue;
					_ignoreProviderChanges = false;
					_stringValue = _numberProvider.stringValue;
				}else{
					_stringValue = String(newVal);
				}
				_validatedValue = newVal;
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
				if(oldStr!=_stringValue && _stringValueChanged){
					_stringValueChanged.perform(this);
				}
			}
		}
		protected function validateValue(value:Number):Number{
			return value;
		}
	}
}