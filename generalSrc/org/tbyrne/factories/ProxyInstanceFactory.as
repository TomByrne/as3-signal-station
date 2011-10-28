package org.tbyrne.factories
{
	import flash.utils.Dictionary;

	public class ProxyInstanceFactory extends BasePooledInstanceFactory
	{
		public function get nestedFactory():IInstanceFactory{
			return _nestedFactory;
		}
		public function set nestedFactory(value:IInstanceFactory):void{
			clearCache();
			_nestedFactory = value;
		}
		
		public function get useChildFactories():Boolean{
			return _useChildFactories;
		}
		public function set useChildFactories(value:Boolean):void{
			_useChildFactories = value;
		}
		
		public function get objectProps():*{
			return _objectProps;
		}
		public function set objectProps(value:*):void{
			if(value){
				_objectProps = new Dictionary();
				addProps(value);
			}else{
				_objectProps = null;
			}
		}
		
		
		private var _nestedFactory:IInstanceFactory;
		private var _instanceClass:Class;
		private var _objectProps:Dictionary;
		
		public function ProxyInstanceFactory(nestedFactory:IInstanceFactory=null, objectProps:*=null, useChildFactories:Boolean=false){
			this.nestedFactory = nestedFactory;
			this.objectProps = objectProps;
			this.useChildFactories = useChildFactories;
		}
		override public function createInstance():*{
			var object:* = _nestedFactory.createInstance();
			initialiseInstance(object);
			return object;
		}
		override public function initialiseInstance(object:*):void{
			fillObject(object,_objectProps,true,true);
		}
		override public function matchesType(object:*):Boolean{
			return _nestedFactory.matchesType(object);
		}
		override public function returnInstance(object:*):void{
			deinitialiseInstance(object);
			_nestedFactory.returnInstance(object);
		}
		
		public function addProps(value:*):void{
			if(!_objectProps)_objectProps = new Dictionary();
			for(var i:String in value){
				addProp(i, value[i]);
			}
		}
		public function addProp(prop:String, value:*):void{
			if(!_objectProps)_objectProps = new Dictionary();
			_objectProps[prop] = value;
		}
		public function removeProps(value:*):void{
			if(!_objectProps)return;
			for(var i:String in value){
				removeProp(i, value[i]);
			}
		}
		public function removeProp(prop:String, ifEquals:*=null):void{
			if(!_objectProps)_objectProps = new Dictionary();
			if(ifEquals==null || _objectProps[prop]==ifEquals){
				delete _objectProps[prop];
			}
		}
	}
}