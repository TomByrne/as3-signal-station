package org.farmcode.acting.actTypes
{
	public interface IAsynchronousAct extends IAct
	{
		function set allowAutoExecute(value:Boolean):void;
		function execute(endHandler:Function, params:Array):void;
	}
}