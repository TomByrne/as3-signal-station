package org.farmcode.hoborg
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	[Event(name="objectReleased",type="org.farmcode.hoborg.events.PoolingEvent")]
	public class Pooler
	{
		public static function setPoolSize(classPath:*, size:uint):*{
			var pool:ObjectPool = getPool(classPath);
			pool.size = size;
		}
		public static function getPoolSize(classPath:*):uint{
			var pool:ObjectPool = getPool(classPath);
			return pool.size;
		}
		
		
		private static var pools:Dictionary = new Dictionary();
		
		public static function takeObject(classPath:*):*{
			var pool:ObjectPool = getPool(classPath);
			return pool.takeObject();
		}
		public static function releaseObject(object:IPoolable):void{
			var pool:ObjectPool = getPool(object);
			pool.releaseObject(object);
		}
		
		
		
		protected static function getPool(klass:*):ObjectPool{
			if(!(klass is Class)){
				if(klass is String){
					klass = getDefinitionByName(klass);
				}else{
					klass = klass["constructor"]
				}
			}
			var ret:ObjectPool = pools[klass];
			if(!ret){
				var pool:ObjectPool = new ObjectPool(klass);
				ret = pools[klass] = pool;
			}
			return ret;
		}
	}
}