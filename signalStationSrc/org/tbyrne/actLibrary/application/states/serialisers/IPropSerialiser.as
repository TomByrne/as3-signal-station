package org.tbyrne.actLibrary.application.states.serialisers
{
	public interface IPropSerialiser
	{
		function serialise(object:*):String;
		function deserialise(string:String):*;
	}
}