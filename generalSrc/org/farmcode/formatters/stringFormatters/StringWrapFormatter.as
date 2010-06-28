package org.farmcode.formatters.stringFormatters
{
	import org.farmcode.data.dataTypes.IStringProvider;
	
	public class StringWrapFormatter extends AbstractStringFormatter
	{
		
		public function get appendString():String{
			return _appendString;
		}
		public function set appendString(value:String):void{
			if(_appendString!=value){
				_appendString = value;
				invalidateString();
			}
		}
		
		public function get prependString():String{
			return _prependString;
		}
		public function set prependString(value:String):void{
			if(_prependString!=value){
				_prependString = value;
				invalidateString();
			}
		}
		
		private var _prependString:String;
		private var _appendString:String;
		
		public function StringWrapFormatter(stringProvider:IStringProvider=null, prependString:String=null, appendString:String=null)
		{
			super(stringProvider);
			this.prependString = prependString;
			this.appendString = appendString;
		}
		override protected function formatString(input:String):String{
			if(input){
				if(_prependString){
					input = _prependString+input;
				}
				if(_appendString){
					input += _appendString;
				}
			}
			return input;
		}
		override protected function unformatString(formatted:String):String{
			if(_prependString && formatted.indexOf(_prependString)==0){
				formatted = formatted.slice(_prependString.length);
			}
			if(_appendString && formatted.indexOf(_appendString)==_appendString.length-_appendString.length){
				formatted = formatted.slice(0,_appendString.length-_appendString.length);
			}
			return formatted;
		}
	}
}