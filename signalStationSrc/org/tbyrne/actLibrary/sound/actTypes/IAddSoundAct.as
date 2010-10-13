package org.tbyrne.actLibrary.sound.actTypes
{
	
	public interface IAddSoundAct extends ISoundControlAct
	{
		/**
		 * Whether or not this advice should wait till the sound has finished playing before continuing.
		 */
		function get continueAfterCompletion(): Boolean;
		
	}
}