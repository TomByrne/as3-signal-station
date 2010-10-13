package org.tbyrne.actLibrary.external.config.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISetConfigParamAct extends IUniversalAct
	{
		function get paramName():String;
		function get value():*;
	}
}