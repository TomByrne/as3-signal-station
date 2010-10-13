package org.tbyrne.display.assets.assetTypes
{
	public interface IContainerAsset extends IInteractiveObjectAsset
	{
		function takeAssetByName(name:String, type:Class, optional:Boolean=false):*;
		function returnAsset(asset:IDisplayAsset):void;
		
		function addAsset(asset:IDisplayAsset):void;
		function removeAsset(asset:IDisplayAsset):void;
		
		function containsAssetByName(name:String):Boolean;
		function contains(child:IDisplayAsset):Boolean;
		
		function getAssetIndex(asset:IDisplayAsset):int;
		function setAssetIndex(asset:IDisplayAsset, index:int):void;
		function addAssetAt(asset:IDisplayAsset, index:int):IDisplayAsset;
		function getAssetAt(index:int):IDisplayAsset;
		
		function get mouseChildren():Boolean;
		function set mouseChildren(value:Boolean):void;
		
		function get numChildren():int;
	}
}