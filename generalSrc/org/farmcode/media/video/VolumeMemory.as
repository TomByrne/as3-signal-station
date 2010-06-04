package org.farmcode.media.video
{
	import flash.net.SharedObject;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	
	public class VolumeMemory implements IVideoSource
	{
		private static var _storage:SharedObject;
		private static var _instances:Array;
		
		private static function registerInstance(inst:VolumeMemory):void{
			if(!_instances)_instances = [];
			if(!_storage)_storage = SharedObject.getLocal("org.farmcode.media.video.VolumeMemory");
			if(_storage.data.volume==null)_storage.data.volume = 1;
			if(_storage.data.muted==null)_storage.data.muted = false;
			
			inst.volume = _storage.data.volume;
			inst.muted = _storage.data.muted;
			
			inst.volumeChanged.addHandler(onVolumeChanged);
			inst.mutedChanged.addHandler(onMutedChanged);
			
			_instances.push(inst);
		}
		private static function unregisterInstance(inst:VolumeMemory):void{
			inst.volumeChanged.removeHandler(onVolumeChanged);
			inst.mutedChanged.removeHandler(onMutedChanged);
			
			var index:int = _instances.indexOf(inst);
			if(index!=-1){
				_instances.splice(index,1);
			}
		}
		private static function onVolumeChanged(from:IVideoSource):void{
			_storage.data.volume = from.volume;
			for each(var inst:VolumeMemory in _instances){
				inst.volume = inst.volume;
			}
		}
		private static function onMutedChanged(from:IVideoSource):void{
			_storage.data.muted = from.muted;
			for each(var inst:VolumeMemory in _instances){
				inst.muted = inst.muted;
			}
		}
		
		
		public function get videoSource():IVideoSource{
			return _videoSource;
		}
		public function set videoSource(value:IVideoSource):void{
			if(_videoSource!=value){
				_videoSource = value;
			}
		}
		
		private var _videoSource:IVideoSource;
		private var _displayCount:int=0;
		
		public function VolumeMemory(videoSource:IVideoSource=null){
			this.videoSource = videoSource;
		}
		
		public function get playingChanged():IAct{
			return _videoSource.playingChanged;
		}
		public function set playing(value:Boolean):void{
			_videoSource.playing = value;
		}
		public function get playing():Boolean{
			return _videoSource.playing;
		}
		public function get bufferedChanged():IAct{
			return _videoSource.bufferedChanged;
		}
		public function get buffered():Boolean{
			return _videoSource.buffered;
		}
		public function get currentTimeChanged():IAct{
			return _videoSource.currentTimeChanged;
		}
		public function set currentTime(value:Number):void{
			_videoSource.currentTime = value;
		}
		public function get currentTime():Number{
			return _videoSource.currentTime;
		}
		public function get totalTimeChanged():IAct{
			return _videoSource.totalTimeChanged;
		}
		public function get totalTime():Number{
			return _videoSource.totalTime;
		}
		public function get volumeChanged():IAct{
			return _videoSource.volumeChanged;
		}
		public function set volume(value:Number):void{
			_videoSource.volume = value;
		}
		public function get volume():Number{
			return _videoSource.volume;
		}
		public function get mutedChanged():IAct{
			return _videoSource.mutedChanged;
		}
		public function set muted(value:Boolean):void{
			_videoSource.muted = value;
		}
		public function get muted():Boolean{
			return _videoSource.muted;
		}
		public function get loadProgressChanged():IAct{
			return _videoSource.loadProgressChanged;
		}
		public function get loadProgress():Number{
			return _videoSource.loadProgress;
		}
		public function get loadTotalChanged():IAct{
			return _videoSource.loadTotalChanged;
		}
		public function get loadTotal():Number{
			return _videoSource.loadTotal;
		}
		public function get loadUnits():String{
			return _videoSource.loadUnits;
		}
		public function get loadCompleted():IAct{
			return _videoSource.loadCompleted;
		}
		public function takeMediaDisplay():ILayoutViewBehaviour{
			if(!_displayCount)registerInstance(this);
			++_displayCount;
			return _videoSource.takeMediaDisplay();
		}
		public function returnMediaDisplay(value:ILayoutViewBehaviour):void{
			--_displayCount;
			if(!_displayCount)unregisterInstance(this);
			_videoSource.returnMediaDisplay(value);
		}
	}
}