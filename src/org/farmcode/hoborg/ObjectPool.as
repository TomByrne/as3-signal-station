package org.farmcode.hoborg
{
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.DictionaryUtils;
	
	
	public class ObjectPool
	{
		public function get size():int{
			return _size;
		}
		public function set size(value:int):void{
			if(_size != value){
				_size = value;
				validateSize();
			}
		}
		
		private var _size:int = 0;
		private var pool:Dictionary = new Dictionary();
		private var _constructor:*;
		private var _isClass:Boolean;
		
		public function ObjectPool(constructor:*){
			_constructor = constructor;
			_isClass = (_constructor is Class);
		}
		public function takeObject():*{
			if(_size>0){
				_size--;
				for(var ret:* in pool){
					delete pool[ret];
					return ret;
				}
			}else{
				var ret2:* = createNew();
				return ret2;
			}
		}
		public function releaseObject(object:IPoolable):void{
			if(!pool[object]){
				object.reset();
				pool[object] = true;
				_size++;
			}/*else{
				Config::DEBUG{
					throw new Error("Object has already been released");
				}
			}*/
		}
		protected function validateSize():void{
			var poolLength:Number = DictionaryUtils.getLength(pool);
			var dif:Number = _size-poolLength;
			if(dif<0){
				while(dif<0){
					for(var i:* in pool){
						delete pool[i];
						dif++;
						break;
					}
				}
			}else{
				while(dif>0){
					pool[createNew()] = true;
					dif--;
				}
			}
		}
		protected function createNew():*{
			if(_isClass){
				return new _constructor();
			}else{
				return _constructor();
			}
		}
	}
}
