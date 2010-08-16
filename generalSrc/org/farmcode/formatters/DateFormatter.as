package org.farmcode.formatters
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IDateConsumer;
	import org.farmcode.data.dataTypes.IDateProvider;
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.IValueProvider;
	import org.farmcode.utils.DateFormat;
	
	public class DateFormatter implements IFormatter, IValueProvider
	{
		public function set valueProvider(value:IValueProvider):void{
			dateProvider = value as IDateProvider;
		}
		public function get dateProvider():IDateProvider{
			return _dateProvider;
		}
		public function set dateProvider(value:IDateProvider):void{
			if(_dateProvider!=value){
				if(_dateProvider){
					_dateProvider.dateValueChanged.removeHandler(onProviderChanged);
				}
				_dateProvider = value;
				_dateConsumer = (value as IDateConsumer);
				if(_dateProvider){
					_dateProvider.dateValueChanged.addHandler(onProviderChanged);
					rawDateValue = _dateProvider.dateValue;
				}else{
					rawDateValue = null;
				}
			}
		}
		
		public function get format():String{
			return _dateFormat.formatString;
		}
		public function set format(value:String):void{
			if(_dateFormat.formatString!=value){
				_dateFormat.formatString = value;
				invalidateString();
			}
		}
		
		public function get value():*{
			return _dateValue;
		}
		public function get stringValue():String{
			if(_stringInvalid){
				_stringValue = formatString(_rawDateValue);
				_stringInvalid = false;
			}
			return _stringValue;
		}
		public function set stringValue(value:String):void{
			rawDateValue = parseString(value);
		}
		protected function set rawDateValue(value:Date):void{
			if(_rawDateValue!=value){
				_rawDateValue = value;
				if(_dateConsumer){
					_dateConsumer.dateValue = value;
				}
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
		
		private var _dateProvider:IDateProvider;
		private var _dateConsumer:IDateConsumer;
		private var _ignoreProviderChanges:Boolean;
		private var _rawDateValue:Date;
		private var _stringValue:String;
		private var _dateValue:Date;
		private var _stringValueChanged:Act;
		private var _stringInvalid:Boolean;
		private var _dateFormat:DateFormat = new DateFormat();
		
		public function DateFormatter(dateProvider:IDateProvider=null){
			this.dateProvider = dateProvider;
		}
		protected function invalidateString():void{
			_stringInvalid = true;
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
		protected function formatString(input:Date):String{
			if(!input){
				return "";
			}else{
				return _dateFormat.format(input);
			}
		}
		protected function parseString(formatted:String):Date{
			var ret:Date = _dateFormat.parse(formatted);
			if(ret){
				return ret;
			}else if(_rawDateValue){
				return _rawDateValue;
			}else{
				return null;
			}
		}
		protected function onProviderChanged(from:IDateProvider):void{
			if(!_ignoreProviderChanges){
				rawDateValue = _dateProvider.dateValue;
			}
		}
	}
}