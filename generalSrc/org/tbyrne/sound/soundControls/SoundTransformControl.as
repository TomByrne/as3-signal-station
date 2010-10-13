package org.tbyrne.sound.soundControls
{
	import flash.events.EventDispatcher;
	import flash.media.SoundTransform;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.utils.ObjectUtils;

	public class SoundTransformControl implements ISoundControl
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
		
		
		public function get subject():Object{
			return _subject;
		}
		public function set subject(value:Object):void{
			_subject = value;
			takeVolume();
			renderTransform();
		}
		public function get soundGroup():String{
			return _soundGroup;
		}
		public function set soundGroup(value:String):void{
			_soundGroup = value;
		}
		public function set transformProperty(value:String):void{
			_transformProperty = value;
			renderTransform();
		}
		public function get transformProperty():String{
			return _transformProperty;
		}
		public function set volumeMultiplier(value:Number):void{
			_volumeMultiplier = value;
			takeVolume();
			renderTransform();
		}
		public function get volumeMultiplier():Number{
			return _volumeMultiplier;
		}
		public function get playing():Boolean{
			return _playing;
		}
		public function get infinite():Boolean{
			return true;
		}
		
		private var _added:Boolean;
		
		protected var _soundRemoved:Act;
		protected var _soundAdded:Act;
		protected var _playbackFinished:Act;
		protected var _playbackBegun:Act;
		
		private var _subject:Object;
		private var _soundGroup:String;
		private var _transformProperty:String;
		private var _playing:Boolean;
		private var _volumeMultiplier:Number;
		
		public function SoundTransformControl(subject:Object=null, transformProperty:String="soundTransform"){
			this.subject = subject;
			this.transformProperty = transformProperty;
		}

		public function play():void{
			_playing = true;
			renderTransform();
		}
		public function stop():void{
			_playing = false;
			renderTransform();
		}
		
		protected function renderTransform():void{
			if(_subject && _transformProperty){
				var trans:SoundTransform = ObjectUtils.getProperty(_subject,_transformProperty);
				if(!trans){
					trans = new SoundTransform();
				}
				if(_playing){
					trans.volume = _volumeMultiplier;
				}else{
					trans.volume = 0;
				}
				ObjectUtils.setProperty(_subject,_transformProperty,trans);
			}
		}
		/**
		 * Retrieves the volume from the subject.
		 */
		protected function takeVolume():void{
			if(_subject && _transformProperty && isNaN(_volumeMultiplier)){
				var trans:SoundTransform = ObjectUtils.getProperty(_subject,_transformProperty);
				if(trans)_volumeMultiplier = trans.volume;
			}
		}
	}
}