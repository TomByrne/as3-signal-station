package org.tbyrne.actLibrary.core
{
	import org.tbyrne.acting.actTypes.IUniversalTypeAct;
	
	public interface ISimpleDataAct extends IUniversalTypeAct
	{
		function get actData():*;
		function set actData(value:*):void;
	}
}