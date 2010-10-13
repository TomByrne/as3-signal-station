package org.tbyrne.actLibrary.sound.actTypes
{
	import org.tbyrne.sound.SoundGroupSettings;
	
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IRemoveSoundGroupAct extends IUniversalAct
	{
		function get soundGroup():String;
		function get soundGroupSettings():SoundGroupSettings;
	}
}