package org.tbyrne.display.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;

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