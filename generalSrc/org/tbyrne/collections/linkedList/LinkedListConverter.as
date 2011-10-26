package org.tbyrne.collections.linkedList
{
	import flash.utils.Dictionary;

	public class LinkedListConverter
	{
		public static function fromNativeCollection(collection:*):LinkedList{
			var array:Array = (collection as Array);
			if(array){
				return fromArray(array);
			}else{
				var dict:Dictionary = (collection as Dictionary);
				if(dict){
					return fromDictionary(dict);
				}
			}
			return fromObject(collection);
		}
		public static function fromArray(array:Array):LinkedList{
			var ret:LinkedList = new LinkedList();
			for(var i:int=0; i<array.length; i++){
				var val:* = array[array.length-1-i];
				if(val!=null)ret.unshift(val);
			}
			return ret;
		}
		public static function fromDictionary(dictionary:Dictionary):LinkedList{
			var ret:LinkedList = new LinkedList();
			for each(var obj:* in dictionary){
				ret.unshift(obj);
			}
			return ret;
		}
		public static function fromObject(object:Object):LinkedList{
			var ret:LinkedList = new LinkedList();
			for each(var obj:* in object){
				ret.push(obj);
			}
			return ret;
		}
	}
}