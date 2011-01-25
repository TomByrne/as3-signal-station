package org.tbyrne.display.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public interface IScopedObject 
	{
		
		/**
		 * handler(from:IScopeObject, oldScope:IDisplayObject)
		 */
		function get scopeChanged():IAct;
		function set scope(value:IDisplayObject):void;
		function get scope():IDisplayObject;
	}
}