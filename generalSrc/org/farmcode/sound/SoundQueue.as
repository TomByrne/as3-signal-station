package org.farmcode.sound
{
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.sound.soundControls.IQueueableSoundControl;
	
	[Event(name="playbackFinished",type="org.farmcode.sound.SoundEvent")]
	[Event(name="soundRemoved",type="org.farmcode.sound.SoundEvent")]
	public class SoundQueue implements IPoolable
	{
		
		/**
		 * handler(from:SoundQueue, sound:IQueueableSoundControl)
		 */
		public function get playbackFinished():IAct{
			if(!_playbackFinished)_playbackFinished = new Act();
			return _playbackFinished;
		}
		
		/**
		 * handler(from:SoundQueue, sound:IQueueableSoundControl)
		 */
		public function get soundRemoved():IAct{
			if(!_soundRemoved)_soundRemoved = new Act();
			return _soundRemoved;
		}
		
		protected var _soundRemoved:Act;
		protected var _playbackFinished:Act;
		
		public function get leader():IQueueableSoundControl{
			return sounds[0];
		}
		public function get soundCount():int{
			return sounds.length;
		}
		
		
		public function get playingSound():IQueueableSoundControl{
			return _playingSound;
		}
		public function set playingSound(value:IQueueableSoundControl):void{
			if(_playingSound != value){
				if(_playingSound){
					_playingSound.playbackFinished.removeHandler(onPlayingFinished);
				}
				_playingSound = value;
				if(_playingSound){
					_playingSound.playbackFinished.addHandler(onPlayingFinished);
				}
				
			}
		}
		
		public var queueName:String;
		
		private var _playingSound:IQueueableSoundControl;
		private var sounds:Array;
		
		public function SoundQueue(){
			reset();
		}
		/**
		 * @return Boolean returns false if the sound wasn't added to the queue.
		 */
		public function addSound(sound:IQueueableSoundControl, doingPostpone:Boolean):Boolean{
			if(playingSound && !playingSound.allowQueueInterrupt && !sound.allowQueuePostpone){
				return false;
			}
			
			var i:int=(doingPostpone?1:0);
			while(i<sounds.length){
				var compare:IQueueableSoundControl = (sounds[i] as IQueueableSoundControl);
				if(compare==sound){
					return false;
				}else if(compare.queuePriority<sound.queuePriority && (i!=0 || compare.allowQueueInterrupt) || 
					(compare.queuePriority==sound.queuePriority && compare.allowQueueInterrupt)){
					break;
				}
				i++;
			}
			var added: Boolean = false;
			var first:Boolean = (i==0);
			
			// Resolve conflict of wanting to be head sound while there already is one
			if (first && leader && !leader.allowQueuePostpone){
				var oldLeader:IQueueableSoundControl = leader;
				sounds.splice(0, 1)
				if(_soundRemoved)_soundRemoved.perform(this,oldLeader);
			}
			if(first || sound.allowQueuePostpone){
				sounds.splice(i,0,sound);
				return true;
			}
			return false;
		}
		public function removeSound(sound:IQueueableSoundControl):void{
			var index:int = sounds.indexOf(sound);
			if(index!=-1){
				sounds.splice(index,1);
			}
		}
		public function removeLeader():void{
			sounds.splice(0,1);
		}
		public function hasSound(sound: IQueueableSoundControl): Boolean
		{
			return this.sounds.indexOf(sound) >= 0;
		}
		
		protected function onPlayingFinished(from:IQueueableSoundControl):void{
			this.notifySoundFinished(playingSound);
		}
		
		protected function notifySoundFinished(sound: IQueueableSoundControl): void
		{
			if(_playbackFinished)_playbackFinished.perform(this,sound);
		}
		
		protected function notifySoundRemoved(sound: IQueueableSoundControl): void
		{
			if(_soundRemoved)_soundRemoved.perform(this,sound);
		}
		
		public function reset():void{
			queueName = null;
			sounds = [];
			_playingSound = null;
		}
	}
}