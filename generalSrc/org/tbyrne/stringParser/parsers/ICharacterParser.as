package org.tbyrne.stringParser.parsers
{
	public interface ICharacterParser
	{
		function acceptCharacter(char:String, packetId:String):Vector.<ICharacterParser>;
		function parseCharacter(char:String, packetId:String):Boolean;
	}
}