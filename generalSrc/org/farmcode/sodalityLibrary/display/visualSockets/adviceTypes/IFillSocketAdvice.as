package org.farmcode.sodalityLibrary.display.visualSockets.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;

	public interface IFillSocketAdvice extends IAdvice
	{
		/**
		 * Either displayPath or displaySocket must be set.
		 * @see displaySocket
		 */
		function get displayPath(): String;
		function set displayPath(value: String):void;
		/**
		 * Either displayPath or displaySocket must be set.
		 * @see displayPath
		 */
		function get displaySocket():IDisplaySocket;
		function set displaySocket(value:IDisplaySocket):void;
		function get dataProvider(): *;
	}
}