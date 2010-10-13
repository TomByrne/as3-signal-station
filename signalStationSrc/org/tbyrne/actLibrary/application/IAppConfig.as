package org.tbyrne.actLibrary.application
{
	import org.tbyrne.display.assets.IAssetFactory;

	public interface IAppConfig
	{
		function get assetFactory():IAssetFactory;
		function get initActs():Array;
		function get applicationScale():Number;
	}
}