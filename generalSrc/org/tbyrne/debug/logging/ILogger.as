package org.tbyrne.debug.logging
{
	public interface ILogger
	{
		function log(level:int, ... params):void;
		function setVisibility(level:int):void;
	}
}