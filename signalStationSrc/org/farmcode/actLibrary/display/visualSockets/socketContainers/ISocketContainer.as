package org.farmcode.actLibrary.display.visualSockets.socketContainers
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.core.IView;

	public interface ISocketContainer extends IView
	{
		/**
		 * handler(from:ISocketContainer)
		 */
		function get childSocketsChanged():IAct;
		function get childSockets(): Array;
	}
}