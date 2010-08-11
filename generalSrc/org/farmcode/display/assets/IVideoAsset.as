package org.farmcode.display.assets
{
	import flash.net.NetStream;

	public interface IVideoAsset extends IDisplayAsset
	{
		function attachNetStream(netStream:NetStream):void;
	}
}