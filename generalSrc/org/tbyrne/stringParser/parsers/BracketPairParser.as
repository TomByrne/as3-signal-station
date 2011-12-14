package org.tbyrne.stringParser.parsers
{
	import away3d.animators.data.NullAnimation;

	public class BracketPairParser extends AbstractCharacterParser
	{
		private static const OPEN:String = "open";
		//private static const IGNORE_NEXT:String = "ignoreNext";
		private static const LAST_CHAR:String = "lastChar";
		
		
		
		
		public function get childParsers():Array{
			return _childParsers;
		}
		public function set childParsers(value:Array):void{
			if(_childParsers!=value){
				_childParsers = value;
				if(_childParsers){
					_childVector = Vector.<ICharacterParser>(_childParsers);
				}else{
					_childVector = null;
				}
			}
		}
		
		private var _childParsers:Array;
		
		public var openBracket:String;
		public var closeBracket:String;
		public var escapeChar:String;
		public var childSeperator:String;
		
		private var _childVector:Vector.<ICharacterParser>;
		
		public function BracketPairParser(openBracket:String=null, closeBracket:String=null, escapeChar:String=null, childSeperator:String=null){
			this.openBracket = openBracket;
			this.closeBracket = closeBracket;
			this.escapeChar = escapeChar;
			this.childSeperator = childSeperator;
		}
		
		override public function acceptCharacter(char:String, packetId:String):Vector.<ICharacterParser>{
			if(!getVar(packetId,OPEN)){
				if(char==openBracket){
					// first character
					setVar(packetId,OPEN,true);
					//setVar(packetId,IGNORE_NEXT,true);
					return _selfVector;
				}else{
					return null;
				}
			}else if(!escapeChar || getVar(packetId,LAST_CHAR)!=escapeChar){
				if(char==closeBracket){
					setVar(packetId,LAST_CHAR,null);
					setVar(packetId,OPEN,false);
					//setVar(packetId,IGNORE_NEXT,true);
					return _selfVector;
				}
				
				if(childSeperator && char==childSeperator){
					//setVar(packetId,IGNORE_NEXT,true);
					setVar(packetId,LAST_CHAR,char);
					return _selfVector;
				}
			}
			if(_childVector){
				setVar(packetId,LAST_CHAR,null);
				return _childVector;
			}else{
				setVar(packetId,LAST_CHAR,char);
				return _selfVector;
			}
		}
		
		override public function parseCharacter(char:String, packetId:String):Boolean{
			/*if(getVar(packetId,IGNORE_NEXT)){
				setVar(packetId,IGNORE_NEXT,false);
				return false;
			}else{
				return true;
			}*/
			return false;
		}
		
		/*public function acceptCharacter(char:String):Vector.<ICharacterParser>{
			if(char==openBracket){
				_open = true;
				return true;
			}else{
				return false;
			}
		}
		
		public function parseCharacter(char:String):Boolean{
			if(prevChar==escapeChar){
				return true;
			}else{
				return (char!=escapeChar && char!=closeBracket);
			}
		}
		
		public function checkNextCharacter(char:String, nextChar:String):Vector.<ICharacterParser>{
			if(!_open){
				return null;
			}
			
			if(char!=escapeChar){
				if(nextChar==closeBracket){
					_inside = false;
					_open = false;
					return _selfVector;
				}
				
				if(childSeperator && nextChar==childSeperator){
					_inside = false;
					return _selfVector;
				}
			}
			
			if(!_inside && _childVector){
				_inside = true;
				return _childVector;
			}
			
			return _selfVector;
		}*/
	}
}