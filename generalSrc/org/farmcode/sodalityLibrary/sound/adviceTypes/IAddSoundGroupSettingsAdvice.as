package org.farmcode.sodalityLibrary.sound.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import au.com.thefarmdigital.sound.SoundGroupSettings;

	public interface IAddSoundGroupSettingsAdvice extends IAdvice
	{
		function get soundGroup():String;
		function get soundGroupSettings():SoundGroupSettings;
	}
}