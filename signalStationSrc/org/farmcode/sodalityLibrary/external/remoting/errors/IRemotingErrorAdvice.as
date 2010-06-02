package org.farmcode.sodalityLibrary.external.remoting.errors
{
	import org.farmcode.sodalityLibrary.errors.adviceTypes.IDetailedErrorAdvice;

	public interface IRemotingErrorAdvice extends IDetailedErrorAdvice
	{
		function get method(): String;
		function get parameters(): Array;
	}
}