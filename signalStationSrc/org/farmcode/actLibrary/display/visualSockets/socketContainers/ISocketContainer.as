package org.farmcode.actLibrary.display.visualSockets.socketContainers
{
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;

	public interface ISocketContainer
	{
		function get childSockets(): Array;
	}
}