package org.tbyrne.gateways.interpreters
{
	
	public interface IDataInterpreter
	{
		function incoming(data:*):*;
		function outgoing(data:*):*;
	}
}