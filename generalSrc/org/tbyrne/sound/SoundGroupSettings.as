package org.tbyrne.sound
{
	public class SoundGroupSettings
	{
		public function get volumeMultiplier():Number{
			return _volumeMultiplier;
		}
		public function set volumeMultiplier(value:Number):void{
			_volumeMultiplier = value;
		}
		public function get soundQueue():String{
			return _soundQueue;
		}
		public function set soundQueue(value:String):void{
			_soundQueue = value;
		}
		
		private var _soundQueue:String;
		private var _volumeMultiplier:Number;
		
		public function SoundGroupSettings(volumeMultiplier:Number=1, soundQueue:String=null){
			_soundQueue = soundQueue;
			_volumeMultiplier = volumeMultiplier;
		}
	}
}