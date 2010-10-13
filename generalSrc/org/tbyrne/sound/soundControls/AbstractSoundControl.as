package org.tbyrne.sound.soundControls
{
	import flash.media.SoundTransform;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;

	public class AbstractSoundControl implements ISoundControl, IQueueableSoundControl, IHeroSoundControl
	{
		
		/**
		 * @inheritDoc
		 */
		public function get playbackBegun():IAct{
			if(!_playbackBegun)_playbackBegun = new Act();
			return _playbackBegun;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get playbackFinished():IAct{
			if(!_playbackFinished)_playbackFinished = new Act();
			return _playbackFinished;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get soundAdded():IAct{
			if(!_soundAdded)_soundAdded = new Act();
			return _soundAdded;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get soundRemoved():IAct{
			if(!_soundRemoved)_soundRemoved = new Act();
			return _soundRemoved;
		}
		
		
		public function get added():Boolean{
			return _added;
		}
		public function set added(value:Boolean):void{
			if(_added!=value){
				_added = value;
				if(value){
					if(_soundAdded)_soundAdded.perform(this);
				}else{
					if(_soundRemoved)_soundRemoved.perform(this);
				}
			}
		}
		
		private var _added:Boolean;
		
		protected var _soundRemoved:Act;
		protected var _soundAdded:Act;
		protected var _playbackFinished:Act;
		protected var _playbackBegun:Act;
		
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
		protected function performBegun(): void{
			if(_playbackBegun)_playbackBegun.perform(this);
		}
		protected function performFinished(): void{
			if(_playbackFinished)_playbackFinished.perform(this);
		}
		protected function compileTransform():SoundTransform{
			return new SoundTransform(this.volume*this.volumeMultiplier);
		}
	}
}