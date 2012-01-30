package org.tbyrne.actLibrary.application.states.serialisers
{
	import org.tbyrne.reflection.Deliterator;

	public class SimpleObjectSerialiser implements IPropSerialiser
	{
		public var nameValueSeperator:String;
		public var propDelimiter:String;
		public var begin:String;
		public var end:String;
		
		public function SimpleObjectSerialiser()
		{
		}
		
		public function serialise(object:*):String
		{
			var ret:String = (begin?begin:"");
			var first:Boolean = true;
			for(var i:* in object){
				if(!first){
					if(propDelimiter)ret += propDelimiter;
				}else{
					first = false;
				}
				if(nameValueSeperator){
					ret += i+nameValueSeperator;
				}
				ret += object[i];
			}
			if(end){
				ret += end;
			}
			return ret;
		}
		
		public function deserialise(string:String):*
		{
			if(begin && string.indexOf(begin)==0){
				string = string.substr(begin.length);
			}
			if(end && string.indexOf(end)==string.length-end.length){
				string = string.substr(0,string.length-end.length);
			}
			var props:Array;
			if(propDelimiter){
				props = string.split(propDelimiter);
			}else{
				props = [string];
			}
			var propStr:String;
			if(nameValueSeperator){
				var obj:Object = {};
				for each(propStr in props){
					var pair:Array = propStr.split(nameValueSeperator,2);
					obj[pair[0]] = Deliterator.deliterate(pair[1]);
				}
				return obj;
			}else{
				var array:Array = [];
				for each(propStr in props){
					array.push(Deliterator.deliterate(propStr));
				}
				return array;
			}
		}
	}
}