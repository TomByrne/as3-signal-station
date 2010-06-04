package au.com.thefarmdigital.sound.soundControls
{
	public interface IHeroSoundControl extends ISoundControl
	{
		/**
		 * Whether or not this sound allows other sounds to be played at the same time.
		 * This won't prevent other hero sounds from playing.
		 */
		function get allowOthers(): Boolean;
		/**
		 * Whether other hero sounds playing sound affect the volume of this sound.
		 */
		function get affectedByOtherHeros(): Boolean;
		/**
		 * The minimum volume which other sounds playing concurrently should be multiplied by,
		 * this does not affect other hero sounds playing with affectedByOtherHeros set to true
		 * (depending on other hero sounds playing, this could end up being lower).
		 */
		function get otherVolumeMultiplier():Number;
	}
}