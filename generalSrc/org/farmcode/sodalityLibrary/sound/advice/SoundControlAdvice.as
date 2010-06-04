package org.farmcode.sodalityLibrary.sound.advice
{
	import org.farmcode.sodality.advice.Advice;
	import au.com.thefarmdigital.sound.soundControls.ISoundControl;
	import au.com.thefarmdigital.sound.soundControls.SoundControl;

	public class SoundControlAdvice extends Advice implements ISoundControlAdvice
	{
		protected var _soundControl:ISoundControl;
		
		public function SoundControlAdvice(soundControl:ISoundControl=null, abortable:Boolean=true)
		{
			super(abortable);
			this.soundControl = soundControl;
		}
		
		[Property(toString="true",clonable="true")]
		public function set soundControl(soundControl: ISoundControl): void
		{
			this._soundControl = soundControl;
		}
		public function get soundControl(): ISoundControl
		{
			return this._soundControl;
		}
	}
}