package org.tbyrne.acting.actTypes
{
	public interface IAct
	{
		function perform(... params):void;
		function addHandler(handler:Function, additionalParameters:Array=null):void;
		function addTempHandler(handler:Function, additionalParameters:Array=null):void;
		function removeHandler(handler:Function):void;
	}
}