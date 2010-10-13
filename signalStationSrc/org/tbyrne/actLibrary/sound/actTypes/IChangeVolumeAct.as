package org.tbyrne.actLibrary.sound.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface IChangeVolumeAct extends IUniversalAct
	{
		function get volume(): Number;
		function get muted(): Boolean;
	}
}