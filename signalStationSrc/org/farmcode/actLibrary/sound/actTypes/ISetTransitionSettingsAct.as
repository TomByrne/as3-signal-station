package org.farmcode.actLibrary.sound.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ISetTransitionSettingsAct extends IUniversalAct
	{
		function get easing(): Function;
		function get time(): Number;
	}
}