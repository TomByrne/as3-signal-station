package org.tbyrne.factories
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IInstanceFactory
	{
		function createInstance():*;
		function initialiseInstance(object:*):void;
		
		function returnInstance(object:*):void;
		function deinitialiseInstance(object:*):void;
		/**
		 * Should return true if the object supplied can be repurposed
		 * (using initialiseInstance()) to match this factories output.
		 */
		function matchesType(object:*):Boolean;
	}
}