package org.tbyrne.actLibrary.external.config.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IGetConfigParamAct extends IUniversalAct
	{
		function get paramName():String;
		function set value(value:*):void;
	}
}