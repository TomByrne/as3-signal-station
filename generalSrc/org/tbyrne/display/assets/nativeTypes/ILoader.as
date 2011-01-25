package org.tbyrne.display.assets.nativeTypes
{
	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public interface ILoader extends IDisplayObjectContainer
	{
		function get content():IDisplayObject;
		function get contentLoaderInfo():LoaderInfo;
		function loadBytes(bytes:ByteArray, context:LoaderContext=null):void;
		function unload():void;
	}
}