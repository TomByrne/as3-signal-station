package org.farmcode.formatters.numberFormatters
{
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.formatters.stringFormatters.StringWrapFormatter;
	
	public class CurrencyFormatter extends AbstractNumberFormatter
	{
		public function get currencySymbol():String{
			return stringWrapFormatter.prependString;
		}
		public function set currencySymbol(value:String):void{
			stringWrapFormatter.prependString = value;
		}
		public function get decimalPlaces():int{
			return decimalFormatter.decimalPlaces;
		}
		public function set decimalPlaces(value:int):void{
			decimalFormatter.decimalPlaces = value;
		}
		override public function set numberProvider(value:INumberProvider):void{
			super.numberProvider = value;
			decimalFormatter.numberProvider = value;
		}
		
		public function get displayWhenZero():String{
			return _displayWhenZero;
		}
		public function set displayWhenZero(value:String):void{
			if(_displayWhenZero!=value){
				_displayWhenZero = value;
				invalidateString();
			}
		}
		
		private var _displayWhenZero:String;
		protected var decimalFormatter:DecimalFormatter = new DecimalFormatter();
		protected var stringWrapFormatter:StringWrapFormatter = new StringWrapFormatter(decimalFormatter);
		
		public function CurrencyFormatter(numberProvider:INumberProvider=null, displayWhenZero:String=null){
			super(numberProvider);
			stringWrapFormatter.stringValueChanged.addHandler(onStringChange);
			decimalFormatter.decimalPlaces = 0;
			stringWrapFormatter.prependString = "$";
			this.displayWhenZero = displayWhenZero;
		}
		override protected function formatString(number:Number):String{
			if(_displayWhenZero && (number==0 || isNaN(number)))return _displayWhenZero;
			_ignoreProviderChanges = true;
			decimalFormatter.numericalValue = number;
			_ignoreProviderChanges = false;
			return stringWrapFormatter.stringValue;
		}
		override protected function parseString(string:String):Number{
			if(_displayWhenZero && _displayWhenZero==string)return 0;
			//_ignoreProviderChanges = true;
			stringWrapFormatter.stringValue = string;
			//_ignoreProviderChanges = false;
			return decimalFormatter.numericalValue;
		}
		protected function onStringChange(from:StringWrapFormatter):void{
			if(!_ignoreProviderChanges)invalidateString();
		}
	}
}