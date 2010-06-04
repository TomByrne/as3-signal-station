package org.farmcode.formatters.numberFormatters
{
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.INumberConsumer;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.IValueProvider;
	
	public class AbstractNumberFormatter implements IStringConsumer, IStringProvider, IValueProvider, INumberProvider, INumberConsumer
	{
		
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
					numericalValue = _numberProvider.numericalValue;
				}else{
					numericalValue = NaN;
				}
			}
		}
		public function get value():*{
			return stringValue;
		}
		public function get stringValue():String{
			if(_stringInvalid){
				_stringValue = formatString(numericalValue);
				_stringInvalid = false;
			}
			return _stringValue;
		}
		public function set stringValue(value:String):void{
			var newVal:Number = parseString(value);
			if(numericalValue != newVal){
				numericalValue = newVal;
			}else{
				/* if it's parsed to the same number we must notify 
				any listeners to revert their string*/
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
		}
		public function set numericalValue(value:Number):void{
			if(_numericalValue!=value){
				_numericalValue = value;
				if(_numberConsumer){
					_ignoreProviderChanges = true;
					_numberConsumer.numericalValue = value;
					_ignoreProviderChanges = false;
				}
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
				invalidateString();
			}
		}
		/*public function set numericalValue(value:Number):void{
			if(_numericalValue!=value){
				var newStr:String = formatString(value);
				if(_stringValue!=newStr){
					_stringValue = newStr;
					var newNum:Number = parseString(_stringValue);
					if(_numberConsumer){
						_ignoreProviderChanges = true;
						_numberConsumer.numericalValue = newNum;
						_ignoreProviderChanges = false;
					}
					if(_numericalValue!=newNum){
						_numericalValue = newNum;
						if(_numericalValueChanged)_numericalValueChanged.perform(this);
					}
					_stringInvalid = false;
					if(_stringValueChanged)_stringValueChanged.perform(this);
				}
			}
		}*/
		public function get numericalValue():Number{
			return _numericalValue;
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
		
		/**
		 * @inheritDoc
		 */
		public function get numericalValueChanged():IAct{
			if(!_numericalValueChanged)_numericalValueChanged = new Act();
			return _numericalValueChanged;
		}
		
		protected var _numericalValueChanged:Act;
		protected var _stringValueChanged:Act;
		protected var _numberProvider:INumberProvider;
		protected var _numberConsumer:INumberConsumer;
		protected var _stringValue:String;
		protected var _numericalValue:Number;
		protected var _ignoreProviderChanges:Boolean;
		protected var _stringInvalid:Boolean;
		
		
		public function AbstractNumberFormatter(numberProvider:INumberProvider=null){
			this.numberProvider = numberProvider;
		}
		protected function invalidateString():void{
			_stringInvalid = true;
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
		protected function formatString(number:Number):String{
			// override me (convert value in _numberProvider to string)
			return String(number);
		}
		protected function parseString(string:String):Number{
			// override me (convert _stringValue to Number)
			return parseFloat(string);
		}
		protected function onProviderChanged(from:INumberProvider):void{
			if(!_ignoreProviderChanges){
				numericalValue = _numberProvider.numericalValue;
			}
		}
	}
}