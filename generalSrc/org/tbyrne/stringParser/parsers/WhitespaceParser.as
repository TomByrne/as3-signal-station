package org.tbyrne.stringParser.parsers
{
	import flash.utils.Dictionary;

	public class WhitespaceParser extends AbstractCharacterParser
	{
		public static function get instance():WhitespaceParser{
			if(!_instance){
				_instance = new WhitespaceParser();
			}
			return _instance;
		}
		private static var _instance:WhitespaceParser;
		
		public static const WHITESPACE_CHARS:Array = [" ","\n","\r","\t"];
		
		
		
		public function get characters():Array{
			return _characters;
		}
		public function set characters(value:Array):void{
			if(_characters!=value){
				_characters = value;
				if(_characters){
					_charLookup = new Dictionary();
					for each(var char:String in _characters){
						_charLookup[char] = true;
					}
				}else{
					_charLookup = null;
				}
			}
		}
		
		private var _characters:Array;
		private var _charLookup:Dictionary;
		
		public function WhitespaceParser(characters:Array = null){
			this.characters = (characters || WHITESPACE_CHARS);
		}
		
		override public function acceptCharacter(char:String, packetId:String):Vector.<ICharacterParser>{
			return _charLookup[char]?_selfVector:null;
		}
		
		override public function parseCharacter(char:String, packetId:String):Boolean{
			return false;
		}
	}
}