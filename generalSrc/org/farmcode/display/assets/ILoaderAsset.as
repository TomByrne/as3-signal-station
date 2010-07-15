package org.farmcode.display.assets
{
	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public interface ILoaderAsset extends IContainerAsset
	{
		function get content():IDisplayAsset;
		function get contentLoaderInfo():LoaderInfo;
		function loadBytes(bytes:ByteArray, context:LoaderContext=null):void;
	}
}