package org.farmcode.actLibrary.application
{
	import org.farmcode.display.assets.IAssetFactory;

	public interface IAppConfig
	{
		function get assetFactory():IAssetFactory;
		function get initActs():Array;
		function get applicationScale():Number;
	}
}