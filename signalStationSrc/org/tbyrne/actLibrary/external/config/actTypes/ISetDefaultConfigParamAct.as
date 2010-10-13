package org.tbyrne.actLibrary.external.config.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISetDefaultConfigParamAct extends IUniversalAct
	{
		function get paramName():String;
		function get value():*;
	}
}