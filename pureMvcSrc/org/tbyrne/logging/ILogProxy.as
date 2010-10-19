package org.tbyrne.logging
{
	import org.puremvc.as3.interfaces.IProxy;
	
	public interface ILogProxy extends IProxy
	{
		function getMessagesForLevel(level:int):Vector.<LogInfo>;
	}
}