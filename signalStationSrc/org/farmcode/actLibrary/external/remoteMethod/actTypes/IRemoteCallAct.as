package org.farmcode.actLibrary.external.remoteMethod.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IRemoteCallAct extends IUniversalAct
	{
		function get connectionId():String;
		function get method():String;
		function get parameters():Array;
		
		function set resultType(value:String): void;
		function get resultType(): String;
		
		function set result(value:*): void;
		function get result(): *;
	}
}