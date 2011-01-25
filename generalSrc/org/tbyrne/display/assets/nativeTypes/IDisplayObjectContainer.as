package org.tbyrne.display.assets.nativeTypes
{
	public interface IDisplayObjectContainer extends IInteractiveObject
	{
		function takeAssetByName(name:String, type:Class, optional:Boolean=false):*;
		function returnAsset(asset:IDisplayObject):void;
		
		function addAsset(asset:IDisplayObject):void;
		function removeAsset(asset:IDisplayObject):void;
		
		function containsAssetByName(name:String):Boolean;
		function contains(child:IDisplayObject):Boolean;
		
		function getAssetIndex(asset:IDisplayObject):int;
		function setAssetIndex(asset:IDisplayObject, index:int):void;
		function addAssetAt(asset:IDisplayObject, index:int):IDisplayObject;
		function getAssetAt(index:int):IDisplayObject;
		
		function get mouseChildren():Boolean;
		function set mouseChildren(value:Boolean):void;
		
		function get numChildren():int;
	}
}