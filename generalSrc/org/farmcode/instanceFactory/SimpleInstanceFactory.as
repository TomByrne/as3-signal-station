package org.farmcode.instanceFactory
{
	import flash.utils.Dictionary;

	public class SimpleInstanceFactory extends AbstractInstanceFactory
	{
		/**
		 * The Class used to create each instance.
		 */
		public var instanceClass:Class;
		/**
		 * A dictionary containing properties that get copied into each instance
		 * when it is created.
		 */
		public var instanceProperties:Dictionary;
		
		public function SimpleInstanceFactory(instanceClass:Class=null){
			this.instanceClass = instanceClass;
		}
		
		override public function createInstance():*{
			var ret:* = new instanceClass();
			fillObject(ret, instanceProperties);
			if(_itemCreatedAct)_itemCreatedAct.perform(this,ret);
			return ret;
		}
		override public function initialiseInstance(object:*):void{
			fillObject(object, instanceProperties);
			if(_itemCreatedAct)_itemCreatedAct.perform(this,object);
		}
		override public function matchesType(object:*):Boolean{
			return (object!=null) && (object["constructor"]==instanceClass);
		}
	}
}