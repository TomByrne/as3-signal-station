package org.farmcode.display.assets
{
	public interface IAsset
	{
		function createAsset(type:Class):*;
		function destroyAsset(asset:IAsset):void;
		
		//function get state():String;
		
		/**
		 *  @param stateList A list of state names in order of priority (i.e. if the first one doesn't exist use the second one, etc.)
		 * 
		 */
		function addStateList(stateList:Array):void;
		/**
		 *  @param stateList A list of state names in order of priority (i.e. if the first one doesn't exist use the second one, etc.)
		 * 
		 */
		function removeStateList(stateList:Array):void;
		
		function release():void
	}
}