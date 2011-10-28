package org.tbyrne.factories
{
	import flash.utils.Dictionary;

	public class BasePooledInstanceFactory implements IInstanceFactory
	{
		protected var _pool:Array = [];
		protected var _useChildFactories:Boolean;
		protected var _deinitCache:Dictionary = new Dictionary(true);
		
		
		public function BasePooledInstanceFactory()
		{
		}
		
		public function createInstance():*{
			var object:*;
			if(_pool.length){
				object = _pool.pop();
			}else{
				object = instantiateObject();
			}
			initialiseInstance(object);
			return object;
		}
		
		protected function instantiateObject():*{
			// override me
			Log.error("Must be overriden");
			return null;
		}
		
		public function initialiseInstance(object:*):void{
			// override me
		}
		
		
		
		public function returnInstance(object:*):void{
			deinitialiseInstance(object);
			_pool.push(object);
		}
		
		public function deinitialiseInstance(object:*):void{
			var cache:Dictionary = _deinitCache[object];
			if(cache){
				fillObject(object,cache,false,false);
				delete _deinitCache[object];
			}
		}
		
		public function matchesType(object:*):Boolean{
			// override me
			return false;
		}
		
		
		
		
		protected function fillObject(subject:*, properties:*, assessForFactories:Boolean, cacheForDeinit:Boolean=true):void{
			for(var i:String in properties){
				var value:* = properties[i];
				if(assessForFactories)value = assessValue(value);
				setValue(subject,i,value, cacheForDeinit);
			}
		}
		protected function setValue(subject:*, prop:String, value:*, cacheForDeinit:Boolean=true):void{
			var path:Array = prop.split(".");
			while(path.length>1){
				subject = subject[path.shift()];
			}
			if(cacheForDeinit){
				var props:Dictionary = _deinitCache[subject];
				if(!props){
					props = new Dictionary();
					_deinitCache[subject] = props;
				}
				props[prop] = subject[path[0]];
			}
			subject[path[0]] = value;
		}
		protected function assessValue(value:*):*{
			if(_useChildFactories){
				var cast:IInstanceFactory = (value as IInstanceFactory);
				if(cast){
					value = cast.createInstance();
				}
			}
			return value;
		}
		
		
		protected function clearCache():void{
			_deinitCache = new Dictionary(true);
		}
	}
}