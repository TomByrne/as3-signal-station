package org.tbyrne.memory
{
	import flash.utils.Dictionary;
	
	public class ObjectLocker{
		private static const instances:Dictionary = new Dictionary();
		
		public static function lock(instance:Object):void{
			instances[instance] = true;
		}
		public static function unlock(instance:Object):void{
			delete instances[instance];
		}
		public static function getLockedInstances(type:Class=null):Array{
			var ret:Array = [];
			for(var i:* in instances){
				if(type==null || i is type){
					ret.push(i);
				}
			}
			return ret;
		}
	}
}