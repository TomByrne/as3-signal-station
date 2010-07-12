package org.farmcode.display.core
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.assets.IDisplayAsset;

	public interface IScopedObject 
	{
		
		/**
		 * handler(from:IScopeObject, oldScope:IDisplayAsset)
		 */
		function get scopeChanged():IAct;
		function set scope(value:IDisplayAsset):void;
		function get scope():IDisplayAsset;
	}
}