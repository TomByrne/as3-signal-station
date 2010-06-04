package au.com.thefarmdigital.sound.soundControls
{
	import flash.events.EventDispatcher;
	import flash.media.SoundTransform;
	
	import org.farmcode.utils.ObjectUtils;

	public class SoundTransformControl extends EventDispatcher implements ISoundControl
	{
		
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