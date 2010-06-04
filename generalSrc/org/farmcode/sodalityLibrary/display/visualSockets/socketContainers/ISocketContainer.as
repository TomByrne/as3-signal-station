package org.farmcode.sodalityLibrary.display.visualSockets.socketContainers
{
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;

	public interface ISocketContainer
	{
		function get childSockets(): Array;
	}
}