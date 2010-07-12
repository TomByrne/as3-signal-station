package org.farmcode.acting.actTypes
{
	/**
	 * handler(endHandler:Function, ... params);
	 */
	public interface IAsynchronousAct extends IAct
	{
		function addAsyncHandler(handler:Function, additionalParameters:Array=null):void;
		function removeAsyncHandler(handler:Function):void;
	}
}