package org.farmcode.instanceFactory
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IInstanceFactory
	{
		function createInstance():*;
		function initialiseInstance(object:*):void;
		function matchesType(object:*):Boolean;
		function get itemCreatedAct():IAct; // (instanceFactory:IInstanceFactory, instance:*)
	}
}