package org.tbyrne.display.assets.assetTypes
{
	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public interface ILoaderAsset extends IContainerAsset
	{
		function get content():IDisplayAsset;
		function get contentLoaderInfo():LoaderInfo;
		function loadBytes(bytes:ByteArray, context:LoaderContext=null):void;
		function unload():void;
	}
}