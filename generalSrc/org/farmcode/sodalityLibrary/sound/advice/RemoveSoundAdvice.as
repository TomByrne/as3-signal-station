package org.farmcode.sodalityLibrary.sound.advice
{
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IRemoveSoundAdvice;
	import au.com.thefarmdigital.sound.soundControls.ISoundControl;

	public class RemoveSoundAdvice extends SoundControlAdvice implements IRemoveSoundAdvice
	{
		public function RemoveSoundAdvice(soundControl:ISoundControl=null){
			super(soundControl);
		}
	}
}