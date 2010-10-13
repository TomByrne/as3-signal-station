package org.tbyrne.media.video
{
	import flash.net.SharedObject;
	
	public class VolumeMemory
	{
		private static var _storage:SharedObject;
		private static var _instances:Array;
		
		private static function registerInstance(inst:VolumeMemory):void{
			if(!_instances)_instances = [];
			if(!_storage)_storage = SharedObject.getLocal("org.tbyrne.media.video.VolumeMemory");
			if(_storage.data.volume==null)_storage.data.volume = 1;
			if(_storage.data.muted==null)_storage.data.muted = false;
			
			inst.videoSource.volume = _storage.data.volume;
			inst.videoSource.muted = _storage.data.muted;
			
			inst.videoSource.volumeChanged.addHandler(onVolumeChanged);
			inst.videoSource.mutedChanged.addHandler(onMutedChanged);
			
			_instances.push(inst);
		}
		private static function unregisterInstance(inst:VolumeMemory):void{
			inst.videoSource.volumeChanged.removeHandler(onVolumeChanged);
			inst.videoSource.mutedChanged.removeHandler(onMutedChanged);
			
			var index:int = _instances.indexOf(inst);
			if(index!=-1){
				_instances.splice(index,1);
			}
		}
		private static function onVolumeChanged(from:IVideoSource):void{
			_storage.data.volume = from.volume;
			for each(var inst:VolumeMemory in _instances){
				if(inst.videoSource!=from)inst.videoSource.volume = from.volume;
			}
		}
		private static function onMutedChanged(from:IVideoSource):void{
			_storage.data.muted = from.muted;
			for each(var inst:VolumeMemory in _instances){
				if(inst.videoSource!=from)inst.videoSource.muted = from.muted;
			}
		}
		
		
		public function get videoSource():IVideoSource{
			return _videoSource;
		}
		public function set videoSource(value:IVideoSource):void{
			if(_videoSource!=value){
				if(_videoSource){
					unregisterInstance(this);
				}
				_videoSource = value;
				if(_videoSource){
					registerInstance(this);
				}
			}
		}
		
		private var _videoSource:IVideoSource;
	}
}