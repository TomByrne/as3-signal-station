package org.tbyrne.factories
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;

	public class InstanceFactory extends BasePooledInstanceFactory
	{
		
		public function get useChildFactories():Boolean{
			return _useChildFactories;
		}
		public function set useChildFactories(value:Boolean):void{
			_useChildFactories = value;
		}
		
		public function get instanceClass():Class{
			return _instanceClass;
		}
		public function set instanceClass(value:Class):void{
			_instanceClass = value;
			clearCache();
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
		
		
		private var _instanceClass:Class;
		private var _objectProps:Dictionary;
		
		public function InstanceFactory(instanceClass:Class=null, objectProps:*=null, useChildFactories:Boolean=false){
			this.instanceClass = instanceClass;
			this.objectProps = objectProps;
			this.useChildFactories = useChildFactories;
		}
		override protected function instantiateObject():*{
			return new _instanceClass();
		}
		
		override public function initialiseInstance(object:*):void{
			fillObject(object,_objectProps,true,true);
		}
		override public function matchesType(object:*):Boolean{
			return (object!=null) && (object["constructor"]==instanceClass);
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