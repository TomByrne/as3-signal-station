package org.farmcode.instanceFactory
{
	import flash.utils.Dictionary;

	/**
	 * MultiInstanceFactory allows a factory to create instances based on a class and a
	 * set of property dictionaries. Property dictionaries added with addProperties
	 * are applied in the order that they were added, meaning that later dictionaries
	 * will override former ones.
	 * There is also an optional function hook that can be used to pass all created instances
	 * through a custom function.
	 */
	public class MultiInstanceFactory extends AbstractInstanceFactory
	{
		public function MultiInstanceFactory(instanceClass:Class=null, propertyObject:Object=null){
			this.instanceClass = instanceClass;
			if(propertyObject){
				var propDict:Dictionary = new Dictionary();
				for(var i:String in propertyObject){
					propDict[i] = propertyObject[i];
				}
				addProperties(propDict);
			}
		}
		
		protected var _instanceClass:Class;
		protected var _propertyDicts:Array = [];
		
		
		/**
		 * The Class used to create each instance.
		 */
		public function get instanceClass():Class{
			return _instanceClass;
		}
		public function set instanceClass(value:Class):void{
			_instanceClass = value;
		}
		
		override public function createInstance():*{
			var ret:* = new _instanceClass();
			for each(var props:Dictionary in _propertyDicts){
				fillObject(ret, props);
			}
			if(_itemCreatedAct)_itemCreatedAct.perform(this,ret);
			return ret;
		}
		override public function initialiseInstance(object:*):void{
			for each(var props:Dictionary in _propertyDicts){
				fillObject(object, props);
			}
			if(_itemCreatedAct)_itemCreatedAct.perform(this,object);
		}
		override public function matchesType(object:*):Boolean{
			return (object is _instanceClass);
		}
		public function addProperties(properties:Dictionary):void{
			_propertyDicts.push(properties);
		}
		public function addPropertiesAt(properties:Dictionary, index:int):void{
			_propertyDicts.splice(index,0,properties);
		}
		public function removeProperties(properties:Dictionary):void{
			var index:int = _propertyDicts.indexOf(properties);
			if(index!=-1){
				_propertyDicts.splice(index,1);
			}
		}
	}
}