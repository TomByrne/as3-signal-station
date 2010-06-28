package org.farmcode.formatters.stringFormatters
{
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.IValueProvider;
	import org.farmcode.formatters.IFormatter;
	
	public class AbstractStringFormatter implements IFormatter, IValueProvider
	{
		public function set valueProvider(value:IValueProvider):void{
			stringProvider = value as IStringProvider;
		}
		public function get stringProvider():IStringProvider{
			return _stringProvider;
		}
		public function set stringProvider(value:IStringProvider):void{
			if(_stringProvider!=value){
				if(_stringProvider){
					_stringProvider.stringValueChanged.removeHandler(onProviderChanged);
				}
				_stringProvider = value;
				_stringConsumer = (value as IStringConsumer);
				if(_stringProvider){
					_stringProvider.stringValueChanged.addHandler(onProviderChanged);
					rawStringValue = _stringProvider.stringValue;
				}else{
					rawStringValue = null;
				}
			}
		}
		public function get value():*{
			return _stringValue;
		}
		
		public function get stringValue():String{
			if(_stringInvalid){
				_stringValue = formatString(_rawStringValue);
				_stringInvalid = false;
			}
			return _stringValue;
		}
		public function set stringValue(value:String):void{
			rawStringValue = unformatString(value);
		}
		protected function set rawStringValue(value:String):void{
			if(_rawStringValue!=value){
				if(_stringConsumer){
					_ignoreProviderChanges = true;
					_stringConsumer.stringValue = value;
					value = _stringProvider.stringValue;
					_ignoreProviderChanges = false;
					if(_rawStringValue==value){
						return;
					}
				}
				_rawStringValue = value;
				invalidateString();
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
		protected var _stringProvider:IStringProvider;
		protected var _stringConsumer:IStringConsumer;
		protected var _rawStringValue:String;
		protected var _stringValue:String;
		protected var _ignoreProviderChanges:Boolean;
		protected var _stringInvalid:Boolean;
		
		
		public function AbstractStringFormatter(stringProvider:IStringProvider=null){
			this.stringProvider = stringProvider;
		}
		protected function invalidateString():void{
			_stringInvalid = true;
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
		protected function formatString(input:String):String{
			// override me (format input to string)
			return input;
		}
		protected function unformatString(formatted:String):String{
			// override me (unformat formatted to String)
			return formatted;
		}
		protected function onProviderChanged(from:IStringProvider):void{
			if(!_ignoreProviderChanges){
				rawStringValue = _stringProvider.stringValue;
			}
		}
	}
}