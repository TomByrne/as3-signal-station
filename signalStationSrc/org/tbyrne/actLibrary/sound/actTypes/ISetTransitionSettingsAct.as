package org.tbyrne.actLibrary.sound.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISetTransitionSettingsAct extends IUniversalAct
	{
		function get easing(): Function;
		function get time(): Number;
	}
}