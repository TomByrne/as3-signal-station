package org.tbyrne.actLibrary.logging
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ILogAct extends IUniversalAct
	{
		function get level():int;
		function get params():Array;
	}
}