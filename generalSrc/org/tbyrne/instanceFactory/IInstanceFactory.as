package org.tbyrne.instanceFactory
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IInstanceFactory
	{
		function createInstance():*;
		function initialiseInstance(object:*):void;
		/**
		 * Should return true if the object supplied can be repurposed
		 * (using initialiseInstance()) to match this factories output.
		 */
		function matchesType(object:*):Boolean;
		/**
		 * handler(instanceFactory:IInstanceFactory, instance:*)
		 */
		function get itemCreatedAct():IAct;
	}
}