package org.farmcode.actLibrary.external.config.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IGetConfigParamAct extends IUniversalAct
	{
		function get paramName():String;
		function set value(value:*):void;
	}
}