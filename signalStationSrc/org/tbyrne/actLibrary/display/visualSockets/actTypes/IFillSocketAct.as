package org.tbyrne.actLibrary.display.visualSockets.actTypes
{
	import org.tbyrne.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IFillSocketAct extends IUniversalAct
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