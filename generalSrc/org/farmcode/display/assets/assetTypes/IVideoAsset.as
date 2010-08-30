package org.farmcode.display.assets.assetTypes
{
	import flash.net.NetStream;

	public interface IVideoAsset extends IDisplayAsset
	{
		function attachNetStream(netStream:NetStream):void;
	}
}