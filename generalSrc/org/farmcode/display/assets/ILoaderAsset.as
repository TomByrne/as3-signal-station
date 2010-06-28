package org.farmcode.display.assets
{
	import flash.display.LoaderInfo;

	public interface ILoaderAsset extends IContainerAsset
	{
		function get contentLoaderInfo():LoaderInfo
	}
}