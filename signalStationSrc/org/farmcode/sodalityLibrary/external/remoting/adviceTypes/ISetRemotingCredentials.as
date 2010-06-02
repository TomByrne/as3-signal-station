package org.farmcode.sodalityLibrary.external.remoting.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface ISetRemotingCredentials extends IAdvice
	{
		function get userId():String;
		function get password():String;
	}
}