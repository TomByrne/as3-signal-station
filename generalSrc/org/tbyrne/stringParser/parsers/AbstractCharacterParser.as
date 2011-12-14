package org.tbyrne.stringParser.parsers
{
	import flash.utils.Dictionary;

	public class AbstractCharacterParser implements ICharacterParser
	{
		protected var _selfVector:Vector.<ICharacterParser>;
		
		protected var _varStorage:Dictionary;
		
		public function AbstractCharacterParser(){
			
			_selfVector = new Vector.<ICharacterParser>();
			_selfVector.push(this);
		}
		
		public function acceptCharacter(char:String, packetId:String):Vector.<ICharacterParser>
		{
			return null;
		}
		
		public function parseCharacter(char:String, packetId:String):Boolean
		{
			return false;
		}
		
		protected function setVar(packetId:String, name:String, value:*):void{
			if(!_varStorage){
				_varStorage = new Dictionary();
			}
			var storage:Dictionary = _varStorage[name];
			if(!storage){
				storage = new Dictionary();
				_varStorage[name] = storage;
			}
			storage[packetId] = value;
		}
		protected function getVar(packetId:String, name:String):*{
			if(!_varStorage || !_varStorage[name]){
				return null;
			}else{
				return _varStorage[name][packetId];
			}
			
		}
	}
}