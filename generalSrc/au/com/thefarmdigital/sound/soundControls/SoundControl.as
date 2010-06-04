package au.com.thefarmdigital.sound.soundControls
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundControl extends AbstractSoundControl implements IAccessibleSoundControl
	{
		private var _loops:int;
		private var _sound:Sound;
		private var _currentChannel:SoundChannel;
		protected var _currentCompleteHandler:Function;
		protected var _pausedTime:Number 				= 0;
		protected var _retainPosition:Boolean 				= false;
		private var _textRepresentation:String;
		
		/**
		 * When playing from midway in the sound and looping, the sound must be
		 * manually looped (a limitation of the flash player sound API). These
		 * two variables help deal with that.
		 */
		protected var _loopsDone:Number 				= 0;
		protected var _ignoreLoops:Boolean 				= false;
		
		public function SoundControl(sound:Sound=null, loops: int = 1){
			this.sound = sound;
			this.loops = loops;
		}
		
		public function set loops(loops: int): void{
			this._loops = loops;
		}
		public function get loops(): int{
			return this._loops;
		}
		
		public function get sound(): Sound{
			return this._sound;
		}
		public function set sound(value: Sound): void{
			this._sound = value;
		}
		public function get retainPosition():Boolean{
			return this._retainPosition;
		}
		public function set retainPosition(value: Boolean): void{
			this._retainPosition = value;
		}
		
		protected function get currentChannel(): SoundChannel{
			return _currentChannel;
		}
	
		public function get textRepresentation():String{
			return _textRepresentation;
		}
		public function set textRepresentation(value:String):void{
			_textRepresentation = value;
		}
		override public function get infinite():Boolean{
			return loops==0;
		}
		
		
		override public function play():void{
			if(!_pending){
				clearCurrentChannel();
				intro();
				this.dispatchBegun();
				_pending = true;
			}
		}
		override public function stop():void{
			_pending = false;
			if(_currentChannel){
				_pausedTime = loops==1?0:_currentChannel.position%sound.length;
				outro();
			}
		}
		protected function onSoundComplete(e:Event):void{
			_pending = false;
			clearCurrentChannel();
			_pausedTime = 0;
			if(loops==0 || (loops<_loopsDone && !_ignoreLoops)){
				_loopsDone++;
				play();
			}else{
				outro();
			}
		}
		override public function toString(): String{
			return "[SoundControl sound:" + this.sound + "]";
		}
		protected function setCurrentChannel(channel:SoundChannel, completeHandler:Function=null):void{
			clearCurrentChannel();
			_currentCompleteHandler = completeHandler;
			_currentChannel = channel;
			if(completeHandler!=null)_currentChannel.addEventListener(Event.SOUND_COMPLETE, completeHandler);
		}
		protected function clearCurrentChannel():void{
			if(_currentChannel){
				_currentChannel.stop();
				if(_currentCompleteHandler!=null)_currentChannel.removeEventListener(Event.SOUND_COMPLETE, _currentCompleteHandler);
				_currentChannel = null;
			}
		}
		protected function intro():void{
			if(!_retainPosition)_pausedTime = 0;
			_loopsDone = 0;
			_ignoreLoops = (_pausedTime==0);
			// don't use the loops variable (when paused halfway), it only loops back to the _pausedTime
			var loops:int = _ignoreLoops?(this.loops>0?this.loops:99999):0;
			var newChannel: SoundChannel = sound.play(_pausedTime, loops, compileTransform());
			// If you try to play heaps of sounds, play will eventually return null and sound wont play
			if (newChannel != null)
			{
				setCurrentChannel(newChannel,onSoundComplete);
			}
		}
		protected function outro():void{
			clearCurrentChannel();
			this.dispatchFinished();
		}
		override protected function applyVolume():void{
			if(_currentChannel){
				var soundTransform:SoundTransform = compileTransform();
				_currentChannel.soundTransform = soundTransform;
			}
		}
	}
}