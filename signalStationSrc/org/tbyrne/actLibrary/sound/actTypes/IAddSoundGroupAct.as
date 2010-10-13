package org.tbyrne.actLibrary.sound.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.sound.SoundGroupSettings;

	public interface IAddSoundGroupAct extends IUniversalAct
	{
		function get soundGroup():String;
		function get soundGroupSettings():SoundGroupSettings;
	}
}