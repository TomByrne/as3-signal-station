package org.farmcode.actLibrary.external.config.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ISetDefaultConfigParamAct extends IUniversalAct
	{
		function get paramName():String;
		function get value():String;
	}
}