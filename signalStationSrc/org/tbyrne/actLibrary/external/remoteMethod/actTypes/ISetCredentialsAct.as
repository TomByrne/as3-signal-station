package org.tbyrne.actLibrary.external.remoteMethod.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface ISetCredentialsAct extends IUniversalAct
	{
		function get connectionId():String;
		function get userId():String;
		function get password():String;
	}
}