package au.com.thefarmdigital.sound.soundControls
{
	import au.com.thefarmdigital.sound.SoundEvent;
	
	import flash.events.EventDispatcher;
	import flash.media.SoundTransform;

	[Event(name="playbackBegun",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	[Event(name="playbackFinished",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	[Event(name="soundAdded",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	[Event(name="soundRemoved",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	public class AbstractSoundControl extends EventDispatcher implements ISoundControl, IQueueableSoundControl, IHeroSoundControl
	{
		private var _volume:Number;
		private var _volumeMultiplier:Number;
		protected var _pending:Boolean;
		
		private var _soundGroup:String;
		private var _soundQueue:String;
		private var _queuePriority:int = 0;
		private var _allowQueueInterrupt:Boolean = true;
		private var _allowQueuePostpone:Boolean = true;
		
		private var _allowOthers:Boolean = true;
		private var _affectedByOtherHeros:Boolean = true;
		private var _otherVolumeMultiplier:Number = 1;
		
		public function AbstractSoundControl(){
			this._pending = false;
			this.volume = 1;
			this.volumeMultiplier = 1;
		}

		public function play():void{
		}
		
		public function stop():void{
		}
		
		public function get playing():Boolean{
			return this._pending;
		}
		public function get infinite():Boolean{
			return false;
		}
		public function get volumeMultiplier():Number{
			return _volumeMultiplier;
		}
		public function set volumeMultiplier(value:Number):void{
			if(_volumeMultiplier != value){
				_volumeMultiplier = value;
				applyVolume();
			}
		}
		public function get volume():Number{
			return _volume;
		}
		public function set volume(value:Number):void{
			if(_volume != value){
				_volume = value;
				applyVolume();
			}
		}
		public function get soundGroup():String{
			return _soundGroup;
		}
		public function set soundGroup(value:String):void{
			_soundGroup = value;
		}
		
		
		// IQueueableSoundControl implementation
		public function get soundQueue():String{
			return _soundQueue;
		}
		public function set soundQueue(value:String):void{
			_soundQueue = value;
		}
		public function get queuePriority():int{
			return _queuePriority;
		}
		public function set queuePriority(value:int):void{
			_queuePriority = value;
		}
		public function get allowQueueInterrupt():Boolean{
			return _allowQueueInterrupt;
		}
		public function set allowQueueInterrupt(value:Boolean):void{
			_allowQueueInterrupt = value;
		}
		public function get allowQueuePostpone():Boolean{
			return _allowQueuePostpone;
		}
		public function set allowQueuePostpone(value:Boolean):void{
			_allowQueuePostpone = value;
		}
		
		// IHeroSoundControl implementation
		public function get allowOthers():Boolean{
			return _allowOthers;
		}
		public function set allowOthers(value:Boolean):void{
			_allowOthers = value;
		}
		public function get affectedByOtherHeros():Boolean{
			return _affectedByOtherHeros;
		}
		public function set affectedByOtherHeros(value:Boolean):void{
			_affectedByOtherHeros = value;
		}
		public function get otherVolumeMultiplier():Number{
			return _otherVolumeMultiplier;
		}
		public function set otherVolumeMultiplier(value:Number):void{
			_otherVolumeMultiplier = value;
		}
		
		protected function applyVolume(): void{
			
		}
		protected function dispatchBegun(): void{
			this.dispatchEvent(new SoundEvent(this,SoundEvent.PLAYBACK_BEGUN));
		}
		protected function dispatchFinished(): void{
			this.dispatchEvent(new SoundEvent(this,SoundEvent.PLAYBACK_FINISHED));
		}
		protected function compileTransform():SoundTransform{
			return new SoundTransform(this.volume*this.volumeMultiplier);
		}
	}
}