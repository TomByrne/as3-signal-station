package org.farmcode.sodalityLibrary.external.remoting.adviceTypes
{
	import org.farmcode.external.RemotingNetConnection;
	import org.farmcode.sodality.advice.IAdvice;

	public interface IRemotingAdvice extends IAdvice
	{
		function get userId():String;
		function get password():String;
		function get timeout():Number;
		function get netConnection():RemotingNetConnection;
		function get useCredentials():Boolean;
		function get method():String;
		function get parameters():Array;
		
		function set resultType(value:String): void;
		function get resultType(): String;
		
		function set result(value:*): void;
		function get result(): *;
	}
}