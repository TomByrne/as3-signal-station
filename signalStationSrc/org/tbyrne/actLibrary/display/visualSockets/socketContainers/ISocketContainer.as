package org.tbyrne.actLibrary.display.visualSockets.socketContainers
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.core.IView;

	public interface ISocketContainer extends IView
	{
		/**
		 * handler(from:ISocketContainer)
		 */
		function get childSocketsChanged():IAct;
		function get childSockets(): Array;
	}
}