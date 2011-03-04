package org.tbyrne.hoborg
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.collections.DictionaryUtils;
	
	
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
		private var _isPoolable:Boolean;
		private var _testedPoolable:Boolean;
		
		public function ObjectPool(constructor:*){
			_constructor = constructor;
			_isClass = (_constructor is Class);
		}
		public function takeObject():*{
			var ret:*;
			if(_size>0){
				_size--;
				for(ret in pool){
					delete pool[ret];
					return ret;
				}
			}else{
				ret = createNew();
				if(!_testedPoolable){
					_testedPoolable = true;
					_isPoolable = (ret is IPoolable);
				}
				return ret;
			}
		}
		public function releaseObject(object:*):void{
			if(!pool[object]){
				if(_isPoolable)object.reset();
				pool[object] = true;
				_size++;
			}else{
				CONFIG::debug{
					Log.error( "ObjectPool.releaseObject: Object has already been released");
				}
			}
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
