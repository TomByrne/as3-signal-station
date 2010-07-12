package org.farmcode.actLibrary.sound.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface IChangeVolumeAct extends IUniversalAct
	{
		function get volume(): Number;
		function get muted(): Boolean;
	}
}