package org.tbyrne.media.video
{
	import flash.net.SharedObject;
	
	import org.tbyrne.data.dataTypes.IBooleanData;
	
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
			inst.videoSource.muted.booleanValue = _storage.data.muted;
			
			inst.videoSource.volumeChanged.addHandler(onVolumeChanged);
			inst.videoSource.muted.booleanValueChanged.addHandler(onMutedChanged);
			
			_instances.push(inst);
		}
		private static function unregisterInstance(inst:VolumeMemory):void{
			inst.videoSource.volumeChanged.removeHandler(onVolumeChanged);
			inst.videoSource.muted.booleanValueChanged.removeHandler(onMutedChanged);
			
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
		private static function onMutedChanged(from:IBooleanData):void{
			var newVal:Boolean = from.booleanValue;
			_storage.data.muted = newVal;
			for each(var inst:VolumeMemory in _instances){
				if(inst.videoSource.muted!=from)inst.videoSource.muted.booleanValue = newVal;
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