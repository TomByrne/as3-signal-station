package org.tbyrne.sound.soundControls
{
	import flash.events.Event;
	import flash.media.Sound;

	public class IntroOutroSoundControl extends SoundControl
	{
		/**
		 * Whether the intro and outro should be considered symmetrical and therefore
		 * use each others playtime when moving between each other. e.g. If the sound
		 * is stopped halfway through the intro (and symetrical is set to true), the
		 * outro will start playing from it's halfway point.
		 */
		public function get symmetrical():Boolean{
			return _symmetrical;
		}
		public function set symmetrical(value:Boolean):void{
			_symmetrical = value;
			if(!value)outroStartFract = 0;
		}
		
		private var _symmetrical:Boolean = false;
		
		public var introSound:Sound;
		public var outroSound:Sound;
		public var outroStartFract:Number = 0;
		
		public var playingIntro:Boolean;
		public var playingOutro:Boolean;
		
		public function IntroOutroSoundControl(sound:Sound=null, loops:int=0){
			super(sound, loops);
		}
		override protected function intro():void{
			if(introSound){
				playingIntro = true;
				setCurrentChannel(introSound.play(0, 1, compileTransform()),onIntroComplete);
			}else{
				super.intro();
			}
		}
		override protected function outro():void{
			clearCurrentChannel();
			if(outroSound && outroStartFract<1){
				playingOutro = true;
				setCurrentChannel(outroSound.play(outroStartFract*outroSound.length, 1, compileTransform()),onOutroComplete);
			}else{
				if(_playbackFinished)_playbackFinished.perform(this);
			}
		}
		override public function stop():void{
			_pending = false;
			if(currentChannel){
				if(playingIntro){
					outroStartFract = 1-(currentChannel.position/introSound.length);
					clearCurrentChannel();
				}else{
					outroStartFract = 0;
				}
				if(playingOutro){
					clearCurrentChannel();
				}
				if(currentChannel){
					_pausedTime = loops==1?0:currentChannel.position%sound.length;
					clearCurrentChannel();
				}
				outro();
			}
		}
		protected function onIntroComplete(e:Event):void{
			playingIntro = false;
			clearCurrentChannel();
			super.intro();
		}
		protected function onOutroComplete(e:Event):void{
			playingOutro = false;
			clearCurrentChannel();
			if(_playbackFinished)_playbackFinished.perform(this);
		}
	}
}