package org.tbyrne.display.assets.nativeTypes
{
	import flash.net.NetStream;

	public interface IVideo extends IDisplayObject
	{
		function attachNetStream(netStream:NetStream):void;
	}
}