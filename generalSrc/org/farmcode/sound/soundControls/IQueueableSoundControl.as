package org.farmcode.sound.soundControls
{
	public interface IQueueableSoundControl extends ISoundControl
	{
		/**
		 * Two lead sounds with the same soundQueue can't play at the same time.
		 * If this is null it is considered a normal ISoundControl
		 */
		function get soundQueue():String;
		/**
		 * Used to decide which sound in each queue should be played first.
		 * 
		 * @see soundQueue
		 */
		function get queuePriority():int;
		/**
		 * If a higher priority sound enters the same queue half way through playback this variable determines
		 * whether playback is stopped immediately or continued through to the end of the sound before playback
		 * of the new sound begins.
		 * 
		 * @see soundQueue
		 */
		function get allowQueueInterrupt():Boolean;
		/**
		 * This variable controls whether is allowed to be delayed before playback to allow other sounds
		 * (with higher priority) to play first.
		 */
		function get allowQueuePostpone():Boolean;
	}
}