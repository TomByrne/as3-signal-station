package org.farmcode.actLibrary.application
{
	import org.farmcode.display.assets.IDisplayAsset;

	public interface IAppConfig
	{
		function get mainAsset():IDisplayAsset;
		function get initActs():Array;
		function get applicationScale():Number;
	}
}