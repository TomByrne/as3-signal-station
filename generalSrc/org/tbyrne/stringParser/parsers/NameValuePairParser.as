package org.tbyrne.stringParser.parsers
{
	public class NameValuePairParser extends AbstractCharacterParser
	{
		private static const AT_FIRST:String = "atFirst";
		private static const AT_SEPERATOR:String = "atSeperator";
		private static const AT_LAST:String = "atLast";
		
		
		public function get nameParser():ICharacterParser{
			return _nameParser;
		}
		public function set nameParser(value:ICharacterParser):void{
			if(_nameParser!=value){
				_nameParser = value;
				_nameParserVector[0] = value;
			}
		}
		
		public function get valueParsers():Vector.<ICharacterParser>{
			return _valueParsers;
		}
		public function set valueParsers(value:Vector.<ICharacterParser>):void{
			if(_valueParsers!=value){
				_valueParsers = value;
				if(_nameFirst){
					_lastParserVector = value;
				}else{
					_firstParserVector = value;
				}
			}
		}
		
		public function get nameFirst():Boolean{
			return _nameFirst;
		}
		public function set nameFirst(value:Boolean):void{
			if(_nameFirst!=value){
				_nameFirst = value;
				if(_nameFirst){
					_firstParserVector = _nameParserVector;
					_lastParserVector = _valueParsers;
				}else{
					_firstParserVector = _valueParsers;
					_lastParserVector = _nameParserVector;
				}
			}
		}
		
		private var _nameFirst:Boolean;
		private var _valueParsers:Vector.<ICharacterParser>;
		private var _nameParser:ICharacterParser;
		
		private var _nameParserVector:Vector.<ICharacterParser>;
		
		private var _firstParserVector:Vector.<ICharacterParser>;
		private var _lastParserVector:Vector.<ICharacterParser>;
		
		public var seperator:String;
		
		public function NameValuePairParser(nameParser:ICharacterParser=null, valueParsers:Array=null, seperator:String=null){
			_nameParserVector = new Vector.<ICharacterParser>();
			this.nameFirst = true;
			this.nameParser = nameParser;
			if(valueParsers)this.valueParsers = Vector.<ICharacterParser>(valueParsers);
			this.seperator = seperator;
		}
		
		override public function acceptCharacter(char:String, packetId:String):Vector.<ICharacterParser>{
			
			if(!getVar(packetId,AT_FIRST)){
				setVar(packetId,AT_FIRST,true);
				return _firstParserVector;
			}else if(!getVar(packetId,AT_SEPERATOR) && seperator){
				if(seperator==char){
					setVar(packetId,AT_SEPERATOR,true);
					return _selfVector;
				}else{
					return null;
				}
			}else if(!getVar(packetId,AT_LAST) && (_nameFirst || _nameParser.acceptCharacter(char,packetId))){
				setVar(packetId,AT_LAST,true);
				return _lastParserVector;
			}else{
				setVar(packetId,AT_FIRST,false);
				setVar(packetId,AT_SEPERATOR,false);
				setVar(packetId,AT_LAST,false);
				return null;
			}
		}
		
		override public function parseCharacter(char:String, packetId:String):Boolean{
			return false;
		}
	}
}