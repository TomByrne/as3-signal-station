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
		
		protected var decimalFormatter:DecimalFormatter = new DecimalFormatter();
		protected var stringWrapFormatter:StringWrapFormatter = new StringWrapFormatter(decimalFormatter);
		
		public function CurrencyFormatter(numberProvider:INumberProvider=null){
			super(numberProvider);
			stringWrapFormatter.stringValueChanged.addHandler(onStringChange);
			decimalFormatter.decimalPlaces = 2;
			stringWrapFormatter.prependString = "$";
		}
		override protected function formatString(number:Number):String{
			_ignoreProviderChanges = true;
			decimalFormatter.numericalValue = number;
			_ignoreProviderChanges = false;
			return stringWrapFormatter.stringValue;
		}
		override protected function parseString(string:String):Number{
			_ignoreProviderChanges = true;
			stringWrapFormatter.stringValue = string;
			_ignoreProviderChanges = false;
			return decimalFormatter.numericalValue;
		}
		protected function onStringChange(from:IStringProvider):void{
			if(!_ignoreProviderChanges)invalidateString();
		}
	}
}