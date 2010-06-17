package org.farmcode.actLibrary.external.remoteMethod.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface ISetCredentialsAct extends IUniversalAct
	{
		function get connectionId():String;
		function get userId():String;
		function get password():String;
	}
}