package org.farmcode.actLibrary.sound.actTypes
{
	import org.farmcode.sound.SoundGroupSettings;
	
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IRemoveSoundGroupAct extends IUniversalAct
	{
		function get soundGroup():String;
		function get soundGroupSettings():SoundGroupSettings;
	}
}