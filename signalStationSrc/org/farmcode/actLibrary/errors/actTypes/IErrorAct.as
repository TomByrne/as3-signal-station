package org.farmcode.actLibrary.errors.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface IErrorAct extends IUniversalAct
	{
		function get errorType():String;
		function get errorTarget(): Object;
	}
}