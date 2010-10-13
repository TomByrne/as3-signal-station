package org.tbyrne.formatters.patternFormatters
{
	import org.tbyrne.data.dataTypes.IStringProvider;
	
	public class PatternFormatter extends AbstractPatternFormatter
	{
		public function PatternFormatter(pattern:IStringProvider=null){
			super(pattern);
		}
		public function addToken(token:String, stringProvider:IStringProvider):void{
			_addToken(token, stringProvider);
		}
		public function removeToken(token:String):void{
			_removeToken(token);
		}
		public function removeAllTokens():void{
			_removeAllTokens();
		}
	}
}