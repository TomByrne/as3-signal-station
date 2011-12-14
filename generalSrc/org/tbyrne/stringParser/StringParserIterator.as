package org.tbyrne.stringParser
{
	public class StringParserIterator
	{
		
		public function get stringParser():StringParser{
			return _stringParser;
		}
		public function set stringParser(value:StringParser):void{
			_stringParser = value;
		}
		
		private var _stringParser:StringParser;
		
		
		
		public function StringParserIterator(stringParser:StringParser=null){
			this.stringParser = stringParser;
		}
		
		public function iterateSynchronous(func:Function, additionalParams:Array=null):void{
			var params:Array = [null,null,null];
			if(additionalParams){
				params = params.concat();
			}
			var i:int=0;
			var id:String = _stringParser.firstPacketId;
			while(i<_stringParser.totalPackets){
				var parentId:String = _stringParser.getParent(id);
				params[0] = id;
				params[1] = parentId;
				params[2] = _stringParser.getParser(id);
				params[3] = _stringParser.getStrings(id);
				func.apply(null,params);
				
				var newId :String = _stringParser.getFirstChild(id);
				if(!newId){
					newId = getNext(id);
				}
				id = newId;
				++i;
			}
		}
		
		private function getNext(id:String):String{
			var newId:String = _stringParser.getNextSibling(id);
			if(newId)return newId;
			
			var parentId:String = _stringParser.getParent(id);
			if(parentId){
				return getNext(parentId);
			}else{
				return null;
			}
		}
	}
}