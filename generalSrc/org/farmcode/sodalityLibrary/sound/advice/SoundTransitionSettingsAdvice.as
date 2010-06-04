package org.farmcode.sodalityLibrary.sound.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.ISoundTransitionSettingsAdvice;
	
	import fl.transitions.easing.None;

	public class SoundTransitionSettingsAdvice extends Advice implements ISoundTransitionSettingsAdvice
	{
		protected var _time: Number;
		protected var _easing: Function;
		
		public function SoundTransitionSettingsAdvice()
		{
			this.time = 0;
			this.easing = None.easeNone;
		}

		[Property(toString="true",clonable="true")]
		public function get easing():Function
		{
			return this._easing;
		}
		public function set easing(easing: Function): void
		{
			this._easing = easing;
		}
		
		[Property(toString="true",clonable="true")]
		public function get time():Number
		{
			return this._time;
		}
		public function set time(time: Number): void
		{
			this._time = time;
		}
	}
}