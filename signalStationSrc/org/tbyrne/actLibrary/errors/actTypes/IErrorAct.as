package org.tbyrne.actLibrary.errors.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface IErrorAct extends IUniversalAct
	{
		function get errorType():String;
		function get errorTarget(): Object;
	}
}