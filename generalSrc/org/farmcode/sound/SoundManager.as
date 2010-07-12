package org.farmcode.sound
{
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.DictionaryUtils;
	import org.farmcode.hoborg.ObjectPool;
	import org.farmcode.sound.soundControls.IHeroSoundControl;
	import org.farmcode.sound.soundControls.IQueueableSoundControl;
	import org.farmcode.sound.soundControls.ISoundControl;
	
	[Event(name="playbackBegun",type="org.farmcode.sound.SoundEvent")]
	[Event(name="playbackFinished",type="org.farmcode.sound.SoundEvent")]
	public class SoundManager extends EventDispatcher
	{
		private static const queuePool:ObjectPool = new ObjectPool(SoundQueue);
		
		private static const STORAGE_ID: String = "soundSettings";
		private static const MUTED_STORAGE_ID: String = "muted";
		private static const VOLUME_STORAGE_ID: String = "volume";
		
		protected var _allSounds:Dictionary 		= new Dictionary();
		protected var _soundQueues:Dictionary 		= new Dictionary(); // keyed by queue name
		protected var _nonQueuedSounds:Dictionary 	= new Dictionary();
		protected var _nonQueuedPlaying:Dictionary 	= new Dictionary();
		protected var _requestedPlays:Dictionary 	= new Dictionary();
		protected var _requestedStops:Dictionary 	= new Dictionary();
		
		protected var _soundGroups:Dictionary	 	= new Dictionary();
		
		protected var _globalVolume: Number 		= 0.5;
		protected var _muted: Boolean 				= false;
		protected var _settingsId: String;
		protected var _settingsPath: String 		= "/";
		protected var _storageEnabled: Boolean 		= false;
		private var savingEnabled: Boolean;
		
		public var fadeEasing: Function;
		public var fadeDuration: Number 		= 0.5;
		
		public function get settingsId(): String{
			return this._settingsId;
		}
		public function get settingsPath(): String{
			return this._settingsPath;
		}
		public function set muted(muted: Boolean): void{
			if (muted != this._muted){
				this._muted = muted;
				this.saveSettings();
				assessPlayback();
			}
		}
		public function get muted(): Boolean{
			return this._muted;
		}
		public function set globalVolume(globalVolume: Number): void{
			if (this.globalVolume != globalVolume){
				this._globalVolume = globalVolume;
				this.saveSettings();
				assessPlayback();
			}
		}
		public function get globalVolume(): Number{
			return this._globalVolume;
		}
		protected function get actualVolume(): Number{
			var volume: Number = this.globalVolume;
			if (this.muted){
				volume = 0;
			}
			return volume;
		}
		public function get storageEnabled(): Boolean{
			return this._storageEnabled && this.settingsId != null && this.savingEnabled;
		}
		
		public function get pendingSounds(): Array
		{
			return DictionaryUtils.getKeys(this._allSounds);
		}
		
		public function SoundManager()
		{
			this.savingEnabled = true;
		}
		
		public function changeSettingDetails(settingsId:String, settingsPath:String, storageEnabled:Boolean, load:Boolean):void{
			_settingsId = settingsId;
			_settingsPath = settingsPath;
			_storageEnabled = storageEnabled;
			if(load){
				applySettingsBundle(loadSettingsBundle(settingsId,settingsPath));
			}else{
				saveSettings();
			}
		}
		public function addGroupSettings(groupName:String, groupSettings:SoundGroupSettings):void{
			_soundGroups[groupName] = groupSettings;
			assessPlayback();
		}
		public function removeGroupSettings(groupName:String):void{
			delete _soundGroups[groupName];
			assessPlayback();
		}
		public function playSound(sound:ISoundControl):Boolean{
			return _playSound(sound, true);
		}
		protected function _playSound(sound:ISoundControl, dispatchEvent:Boolean):Boolean{
						
			var pendingStop:Boolean = _requestedStops[sound];
			delete _requestedStops[sound];
			_requestedPlays[sound] = true;
			
			var group:SoundGroupSettings = _soundGroups[sound.soundGroup];
			var queueable:IQueueableSoundControl = sound as IQueueableSoundControl;
			var queueName:String = (queueable && queueable.soundQueue?queueable.soundQueue:(group?group.soundQueue:null))
			var inQueue:Boolean = (queueable && queueName);
			
			var ret:Boolean = false;
			
			if(_allSounds[sound] && !pendingStop && !inQueue) {
				// allow queue items through as they won't be played on top of one another
				throw new Error("This ISoundControl object has already been added to the SoundManager");
			}else{
				if(inQueue){
					var queue:SoundQueue = _soundQueues[queueName];
					if(!queue){
						queue = createQueue(queueName);
					}
					if(queue.addSound(queueable,false)){
						_allSounds[sound] = queueName;
						if(queue.leader==sound){
							if(!queue.playingSound){
								assessQueue(queue,false);
							}else if(queue.playingSound.allowQueueInterrupt){
								if(queue.playingSound.allowQueuePostpone && !_requestedStops[queue.playingSound]){
									queue.addSound(queue.playingSound,true);
								}
								_requestedStops[queue.playingSound] = true;
								assessPlayback();
							}
						}
						ret = true;
					}else if(queue && queue.playingSound && queue.playingSound.infinite){
						trace("WARNING: failed to add sound to queue with infinitely playing sound.");
					}
				}else{
					_allSounds[sound] = true;
					_nonQueuedSounds[sound] = true;
					introSound(sound);
					ret = true;
				}
				if(ret && dispatchEvent)sound.dispatchEvent(new SoundEvent(sound,SoundEvent.SOUND_ADDED));
				return ret;
			}
		}
		
		public function isManagingSound(soundControl: ISoundControl): Boolean{
			return this._allSounds[soundControl] != undefined;
		}
		
		public function removeSound(sound:ISoundControl):void{
			if(_allSounds[sound]){
				delete _requestedPlays[sound];
				if(_allSounds[sound] is String){
					var queue:SoundQueue = _soundQueues[_allSounds[sound]];
					if(sound==queue.playingSound){
						_requestedStops[sound] = true;
						assessQueue(queue,true);
					}else{
						var cast:IQueueableSoundControl = sound as IQueueableSoundControl;
						queue.removeSound(cast);
						if(!queue.hasSound(cast))delete _allSounds[sound];
						sound.dispatchEvent(new SoundEvent(sound,SoundEvent.SOUND_REMOVED));
					}
				}else{
					if(_nonQueuedPlaying[sound]){
						_requestedStops[sound] = true;
						assessPlayback();
					}else{
						delete _allSounds[sound];
						sound.dispatchEvent(new SoundEvent(sound,SoundEvent.SOUND_REMOVED));
					}
				}
			}
		}
		
		protected function assessQueue(queue:SoundQueue,forceAssessPlayback:Boolean=false):void{
			if(queue.leader){
				if(queue.leader && !queue.playingSound){
					queue.playingSound = queue.leader;
					queue.removeLeader();
					_requestedPlays[queue.playingSound] = true;
					assessPlayback();
					return;
				}
			}
			if(forceAssessPlayback){
				assessPlayback();
			}
		}
		protected function introSound(sound:ISoundControl):void{
			_nonQueuedPlaying[sound] = true;
			sound.addEventListener(SoundEvent.PLAYBACK_FINISHED, onSoundFinished);
			assessPlayback();
		}
		protected function assessPlayback():void{
			var i:*;
			var sound:ISoundControl;
			var heroSound:IHeroSoundControl;
			var soundGroup:SoundGroupSettings;
			
			var minVol:Number = 1;
			var subjects:Dictionary = new Dictionary();
			var heros:Dictionary = new Dictionary();
			var allowNonHeros:Boolean = true;
			
			var heroSearch:Function = function(sound:ISoundControl):void{
				heroSound = (sound as IHeroSoundControl);
				if(heroSound){
					minVol = Math.min(minVol, heroSound.otherVolumeMultiplier);
					heros[sound] = heroSound;
					if(!heroSound.allowOthers){
						allowNonHeros = false;
					}
				}
				subjects[sound] = true;
			}
			
			for each(var queue:SoundQueue in _soundQueues){
				heroSearch(queue.playingSound);
			}
			for(i in _nonQueuedPlaying){
				sound = (i as ISoundControl);
				heroSearch(sound);
			}
			for(i in subjects){
				sound = (i as ISoundControl);
				soundGroup = _soundGroups[sound.soundGroup];
				heroSound = heros[sound];
				var tween:Boolean = true;
				var groupVol:Number = (soundGroup?soundGroup.volumeMultiplier:1);
				var realVol:Number = ((!heroSound || heroSound.affectedByOtherHeros)?minVol:1)*actualVolume*groupVol;
				if(sound.playing){
					if(_requestedStops[sound]){
						sound.stop();
					}else if((!heroSound || heroSound.affectedByOtherHeros) && !allowNonHeros){
						sound.stop();
						var queueable:IQueueableSoundControl = (sound as IQueueableSoundControl);
						if((!queueable && sound.infinite) || (queueable && queueable.allowQueueInterrupt)){
							_requestedPlays[sound] = true;
						}
					}
				}else if(_requestedPlays[sound] && ((heroSound && !heroSound.affectedByOtherHeros) || allowNonHeros)){
					delete _requestedPlays[sound];
					tween = false;
					setSoundVolume(sound,realVol,false);
					sound.play();
				}
				if(tween)setSoundVolume(sound,realVol,true);
			}
		}
		
		protected function createQueue(queueName:String):SoundQueue{
			var queue:SoundQueue = queuePool.takeObject();
			queue.queueName = queueName
			_soundQueues[queueName] = queue;
			queue.addEventListener(SoundEvent.PLAYBACK_FINISHED, onQueuePlayingFinish);
			queue.addEventListener(SoundEvent.SOUND_REMOVED, onQueueSoundRemoved);
			return queue;
		}
		protected function destroyQueue(queueName:String):void{
			var queue:SoundQueue = _soundQueues[queueName];
			queue.removeEventListener(SoundEvent.PLAYBACK_FINISHED, onQueuePlayingFinish);
			queue.removeEventListener(SoundEvent.SOUND_REMOVED, onQueueSoundRemoved);
			delete _soundQueues[queueName];
			queuePool.releaseObject(queue);
		}
		
		protected function onQueueSoundRemoved(e: SoundEvent): void{
			var queue:SoundQueue = (e.target as SoundQueue);
			var sound:IQueueableSoundControl = e.soundControl as IQueueableSoundControl;
			if(!queue.hasSound(sound)){
				delete _allSounds[sound];
			}
			if(!queue.soundCount){
				destroyQueue(queue.queueName);
			}
			sound.dispatchEvent(new SoundEvent(sound,SoundEvent.SOUND_REMOVED));
			dispatchEvent(new SoundEvent(sound,SoundEvent.PLAYBACK_FINISHED));
		}
		protected function onQueuePlayingFinish(e:SoundEvent):void{
			var queue:SoundQueue = (e.target as SoundQueue);
			var sound:IQueueableSoundControl = e.soundControl as IQueueableSoundControl;
		
			delete _requestedStops[sound];
			queue.playingSound = null;
			if (!queue.hasSound(sound)){
				delete this._allSounds[sound];
			}
			if(!_requestedPlays[sound] || !_playSound(e.soundControl,false)){
				if(queue.soundCount){
					assessQueue(queue,false);
				}else{
					destroyQueue(queue.queueName);
					assessPlayback();
				}
				sound.dispatchEvent(new SoundEvent(sound,SoundEvent.SOUND_REMOVED));
			}
			dispatchEvent(new SoundEvent(sound,SoundEvent.PLAYBACK_FINISHED));
		}
				
		protected function onSoundFinished(e:SoundEvent):void{
			var sound:ISoundControl = (e.target as ISoundControl);
			sound.removeEventListener(SoundEvent.PLAYBACK_FINISHED, onSoundFinished);
			delete _nonQueuedPlaying[sound];
			delete _requestedStops[sound];
			delete _nonQueuedSounds[sound];
			delete _allSounds[sound];
			if(!_requestedPlays[sound] || !_playSound(sound,false)){
				assessPlayback();
				sound.dispatchEvent(new SoundEvent(sound,SoundEvent.SOUND_REMOVED));
			}
			dispatchEvent(new SoundEvent(e.soundControl,SoundEvent.PLAYBACK_FINISHED));
		}
				
		protected function setSoundVolume(sound:ISoundControl, volume:Number, doTween:Boolean):void{
			if(doTween){
				var tween:LooseTween = new LooseTween(sound,{volumeMultiplier:volume},fadeEasing,fadeDuration);
				tween.start();
			}else{
				sound.volumeMultiplier = volume;
			}
		}
		protected function saveSettings(): void{
			if (this.storageEnabled){
				var storage: SharedObject = SharedObject.getLocal(this.settingsId, this.settingsPath);
				storage.data[STORAGE_ID] = this.createSettingsBundle();
				storage.flush();
			}
		}
		protected function loadSettings(): void{
			if (this.storageEnabled){
				var bundle: Object = this.loadSettingsBundle(this.settingsId, this.settingsPath);
				if (bundle != null)
				{
					this.applySettingsBundle(bundle);
				}
			}
		}
		protected function loadSettingsBundle(id: String, path: String): Object{
			var storage: SharedObject = SharedObject.getLocal(id, path);
			return storage.data[STORAGE_ID];
		}
		protected function createSettingsBundle(): Object{
			var bundle: Object = new Object();
			bundle[SoundManager.MUTED_STORAGE_ID] = this.muted;
			bundle[SoundManager.VOLUME_STORAGE_ID] = this.globalVolume;
			return bundle;
		}
		protected function applySettingsBundle(bundle: Object): void{
			if (bundle != null){
				this.savingEnabled = false;
				this.muted = bundle[SoundManager.MUTED_STORAGE_ID];
				this.globalVolume = bundle[SoundManager.VOLUME_STORAGE_ID];
				this.savingEnabled = true;
				this.saveSettings();
			}
		}
		protected function scaleVolumeToGlobal(volume: Number): Number{
			var vol: Number = volume;
			if (this.muted){
				vol = 0;
			}else{
				vol *= this.globalVolume;
			}
			return vol;
		}
		protected function removeArrayItem(item:*, array:Array):void{
			var index:int = array.indexOf(item);
			if(index>=0){
				array.splice(index,1);
			}
		}
	}
}