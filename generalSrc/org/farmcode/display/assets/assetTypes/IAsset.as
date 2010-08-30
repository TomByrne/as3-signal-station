package org.farmcode.display.assets.assetTypes
{
	import org.farmcode.display.assets.IAssetFactory;

	public interface IAsset
	{
		function get factory():IAssetFactory;
		
		function get useParentStateLists():Boolean;
		function set useParentStateLists(value:Boolean):void;
		
		/**
		 *  @param stateList A list of state names in order of priority (i.e. if the first one doesn't exist use the second one, etc.)
		 *  @param fromParentAsset should be true when the stateList is cascading down from a parent asset.
		 */
		function addStateList(stateList:Array, fromParentAsset:Boolean):void;
		/**
		 *  @param stateList A list of state names in order of priority (i.e. if the first one doesn't exist use the second one, etc.)
		 * 
		 */
		function removeStateList(stateList:Array):void;
		
		/**
		 * Allows checking of whether this asset implements a particular Asset interface.
		 * Performing this test in a method (as opposed to using the 'as' keyword) allows
		 * classes to implement interfaces without supporting them at runtime.
		 */
		function conformsToType(type:Class):Boolean;
	}
}