package org.tbyrne.sound.soundControls
{
	import flash.media.Sound;

	public class PlayRandomSoundControl extends SoundControl
	{
		// TODO: Sound options be an array of sound controls so can use same loops, volume etc
		private var _options: Array;
		private var _resetOnComplete: Boolean;
		
		public function PlayRandomSoundControl(options: Array = null, loops:int=0)
		{
			super(null, loops);
			
			this.options = options;
			this.resetOnComplete = false;
		}
		
		public function set resetOnComplete(value: Boolean): void
		{
			this._resetOnComplete = value;
		}
		public function get resetOnComplete(): Boolean
		{
			return this._resetOnComplete;
		}
		
		public function set options(value: Array): void
		{
			this._options = value;
			this.chooseOption();
		}
		public function get options(): Array
		{
			return this._options;
		}
		
		public function chooseOption(): void
		{
			if (this.options != null && this.options.length > 0)
			{
				var randIndex: int = Math.floor(Math.random() * this.options.length);
				this.sound = this.options[randIndex];
			}else{
				this.sound = null;
			}
		}
		
		override protected function outro():void
		{
			super.outro();
			if (this.resetOnComplete)
			{
				this.chooseOption();
			}
		}
	}
}