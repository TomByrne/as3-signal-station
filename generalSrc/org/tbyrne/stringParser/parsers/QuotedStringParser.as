package org.tbyrne.stringParser.parsers
{
	import flash.utils.Dictionary;

	public class QuotedStringParser extends AbstractCharacterParser
	{
		public static const QUOTE_TYPES:Array = ["'",'"'];
		public static const ESCAPE_CHAR:String = "\\";
		
		private static const OPEN:String = "open";
		private static const IGNORE_NEXT:String = "ignoreNext";
		private static const LAST_CHAR:String = "lastChar";
		private static const OPENED_QUOTE:String = "openedQuote";
		
		public function get quoteTypes():Array{
			return _quoteTypes;
		}
		public function set quoteTypes(value:Array):void{
			if(_quoteTypes!=value){
				_quoteTypes = value;
				if(_quoteTypes){
					_quoteLookup = new Dictionary();
					for each(var char:String in _quoteTypes){
						_quoteLookup[char] = true;
					}
				}else{
					_quoteLookup = null;
				}
			}
		}
		
		private var _quoteTypes:Array;
		private var _quoteLookup:Dictionary;
		
		public var escapeChar:String;
		
		public function QuotedStringParser(quoteTypes:Array=null, escapeChar:String = null){
			super();
			
			this.quoteTypes = (quoteTypes || QUOTE_TYPES);
			this.escapeChar = (escapeChar || ESCAPE_CHAR);
		}
		
		
		override public function acceptCharacter(char:String, packetId:String):Vector.<ICharacterParser>{
			if(!getVar(packetId,OPEN)){
				if(_quoteLookup[char]){
					// first character
					setVar(packetId,OPENED_QUOTE,char);
					setVar(packetId,OPEN,true);
					setVar(packetId,IGNORE_NEXT,true);
					return _selfVector;
				}else{
					return null;
				}
			}else if(!escapeChar || getVar(packetId,LAST_CHAR)!=escapeChar){
				if(char==getVar(packetId,OPENED_QUOTE)){
					setVar(packetId,OPENED_QUOTE,null);
					setVar(packetId,LAST_CHAR,null);
					setVar(packetId,OPEN,false);
					setVar(packetId,IGNORE_NEXT,true);
					return _selfVector;
				}
			}
			setVar(packetId,LAST_CHAR,char);
			return _selfVector;
		}
		
		override public function parseCharacter(char:String, packetId:String):Boolean{
			if(getVar(packetId,IGNORE_NEXT)){
				setVar(packetId,IGNORE_NEXT,false);
				return false;
			}else{
				return true;
			}
		}
	}
}