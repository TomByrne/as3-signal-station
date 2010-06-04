package org.farmcode.display.assets
{
	public interface IContainerAsset extends IInteractiveObjectAsset
	{
		function takeAssetByName(name:String, type:Class, optional:Boolean=false):*;
		function returnAsset(asset:IAsset):void;
		
		function addAsset(asset:IAsset):void;
		function removeAsset(asset:IAsset):void;
		
		function containsAssetByName(name:String):Boolean;
		
		function setAssetIndex(asset:IAsset, index:int):void;
		
		function get mouseChildren():Boolean;
		function set mouseChildren(value:Boolean):void;
		
		function get numChildren():int;
	}
}