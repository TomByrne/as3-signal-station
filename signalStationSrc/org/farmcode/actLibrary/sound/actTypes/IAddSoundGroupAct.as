package org.farmcode.actLibrary.sound.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.sound.SoundGroupSettings;

	public interface IAddSoundGroupAct extends IUniversalAct
	{
		function get soundGroup():String;
		function get soundGroupSettings():SoundGroupSettings;
	}
}