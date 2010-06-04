package org.farmcode.sodalityLibrary.sound.adviceTypes
{
	import org.farmcode.sodalityLibrary.sound.advice.ISoundControlAdvice;
	
	public interface IAddSoundAdvice extends ISoundControlAdvice
	{
		/**
		 * Whether or not this advice should wait till the sound has finished playing before continuing.
		 */
		function get continueAfterCompletion(): Boolean;
		
	}
}