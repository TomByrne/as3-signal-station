package org.farmcode.media.video
{
	import au.com.thefarmdigital.display.MediaView;
	import au.com.thefarmdigital.utils.VideoBufferCalculator;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetConnectionStatus;
	import flash.net.NetStream;
	import flash.net.NetStreamStatus;
	import flash.utils.getTimer;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IVideoAsset;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;
	import org.farmcode.display.assets.nativeAssets.VideoAsset;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.layout.frame.FrameLayoutInfo;
	import org.farmcode.media.MediaSource;
	import org.farmcode.media.MediaViewBehaviour;
	
	public class AbstractVideoSource extends MediaSource implements IVideoSource
	{
		protected static const MEMORY_LOAD_UNITS:String = "Kb";
		protected static const TIME_LOAD_UNITS:String = "s";
		
		
		
		/**
		 * @inheritDoc
		 */
		public function get playingChanged():IAct{
			if(!_playingChanged)_playingChanged = new Act();
			return _playingChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bufferedChanged():IAct{
			if(!_bufferedChanged)_bufferedChanged = new Act();
			return _bufferedChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get currentTimeChanged():IAct{
			if(!_currentTimeChanged)_currentTimeChanged = new Act();
			return _currentTimeChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get totalTimeChanged():IAct{
			if(!_totalTimeChanged)_totalTimeChanged = new Act();
			return _totalTimeChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get volumeChanged():IAct{
			if(!_volumeChanged)_volumeChanged = new Act();
			return _volumeChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mutedChanged():IAct{
			if(!_mutedChanged)_mutedChanged = new Act();
			return _mutedChanged;
		}
		
		
		public function get playing():Boolean{
			return _playing;
		}
		public function set playing(value:Boolean):void{
			if(_playing!=value){
				_playing = value;
				if(_playingChanged)_playingChanged.perform(this);
				if(_streamPlaying!=value){
					if(value){
						assessStream();
						if(_buffered){
							_streamPlaying = true;
							_netStream.resume();
							if(_netStream.time==totalTime){
								currentTime = 0;
							}
						}
					}else if(_videoStreamProxy.metadataReceived){
						_streamPlaying = false;
						_netStream.pause();
					}
					assessBufferSize();
				}
			}
		}
		
		public function get buffered():Boolean{
			return _buffered;
		}
		
		public function get currentTime():Number{
			return _currentTime;
		}
		public function set currentTime(value:Number):void{
			if(_streamStarted){
				var toEnd:Boolean;
				var end:Number = _netStream.time+_netStream.bufferLength;
				if(value>=end){
					value = end;
					toEnd = true;
				}
				value = Math.min(value,_netStream.time+_netStream.bufferLength);
				if(_currentTime!=value){
					_currentTime = value;
					_pendingSeek = true;
					setBuffered(false);// seeking will force the playhead to wait for the large buffer to be reached without this.
					_netStream.seek(value);
					if(_currentTimeChanged)_currentTimeChanged.perform(this);
				}
			}
		}
		
		public function get totalTime():Number{
			return (!_streamStarted || isNaN(_videoStreamProxy.duration))?0:_videoStreamProxy.duration;
		}
		
		public function get volume():Number{
			return _volume;
		}
		public function set volume(value:Number):void{
			if(_volume!=value){
				_volume = value;
				assessVolume();
				if(_volumeChanged)_volumeChanged.perform(this);
			}
		}
		
		public function get muted():Boolean{
			return _muted;
		}
		public function set muted(value:Boolean):void{
			if(_muted!=value){
				_muted = value;
				assessVolume();
				if(_mutedChanged)_mutedChanged.perform(this);
			}
		}
		/**
		 * useTotalForProgress determines whether the progress properties
		 * and events provided by this video represent the total load
		 * progress or the progress of filling the buffer.
		 */
		public function get useTotalForProgress():Boolean{
			return _useTotalForProgress;
		}
		public function set useTotalForProgress(value:Boolean):void{
			if(_useTotalForProgress!=value){
				_useTotalForProgress = value;
			}
		}
		override public function get loadUnits():String{
			if(_streamStarted){
				return !isNaN(_videoStreamProxy.duration)?TIME_LOAD_UNITS:MEMORY_LOAD_UNITS;
			}else{
				return null;
			}
		}
		
		protected var _streamStarted:Boolean;
		protected var _volume:Number = 1;
		protected var _muted:Boolean;
		protected var _currentTime:Number;
		protected var _buffered:Boolean;
		protected var _playing:Boolean;
		protected var _useTotalForProgress:Boolean;
		protected var _smallBuffer:Number;
		protected var _displaysTaken:int = 0;
		
		protected var _loadingStartAt:Number;
		protected var _loadingByteOffset:Number;
		
		/**
		 * Represents whether the NetStream is in 'play' mode NOT whether it's actually playing.
		 * If the NetStream is in play mode and hasn't filled it's buffer and has an opportunity
		 * to pause playback (e.g. a seek is requested) then it will pause (and this variable will
		 * remain true).
		 */
		protected var _streamPlaying:Boolean;
		protected var _pendingSeek:Boolean;
		protected var _videoPoller:DelayedCall = new DelayedCall(pollVideo,1,false,null,0);
		
		protected var _netStream:NetStream;
		protected var _videoStreamProxy:VideoStreamProxy;
		
		protected var _displayMeasurements:Rectangle = new Rectangle(0,0,320,240);
		
		protected var _volumeChanged:Act;
		protected var _totalTimeChanged:Act;
		protected var _currentTimeChanged:Act;
		protected var _bufferedChanged:Act;
		protected var _playingChanged:Act;
		protected var _mutedChanged:Act;
		
		public function AbstractVideoSource(){
			super();
		}
		protected function closeStream():void{
			if(_streamStarted){
				_streamStarted = false;
				_netStream.close();
				_netStream = null;
				_currentTime = 0;
				setBuffered(false);
				updateDisplayMeasurements(0,0,320,240);
				
				for(var i:* in _allMediaDisplays){
					var mediaView:MediaViewBehaviour = (i as MediaViewBehaviour);
					(mediaView.asset as Video).attachNetStream(null);
				}
			}
		}
		protected function assessStream():void{
			if(_streamStarted){
				if(!_displaysTaken){
					closeStream();
					_videoPoller.clear();
				}
			}else if(_displaysTaken && _playing){
				_netStream = createNetStream();
				if(_netStream){
					_streamStarted = true;
					_streamPlaying = true;
					
					_videoStreamProxy = new VideoStreamProxy();
					_videoStreamProxy.metadataChanged.addHandler(onMetadata);
					_netStream.client = _videoStreamProxy;
					_netStream.addEventListener(NetStatusEvent.NET_STATUS,onStreamStatus);
					_netStream.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					
					_videoPoller.begin();
					assessVolume();
					assessBufferSize();
					for(var i:* in _allMediaDisplays){
						var mediaView:MediaViewBehaviour = (i as MediaViewBehaviour);
						(mediaView.asset as Video).attachNetStream(_netStream);
					}
				}
			}
		}
		protected function createNetStream():NetStream{
			// override me
			return null;
		}
		protected function onStreamStatus(e:NetStatusEvent):void{
			switch(e.info.code){
				case NetStreamStatus.PLAY_START:
					assessBufferSize();
					if(!_playing && _videoStreamProxy.metadataReceived){
						_streamPlaying = false;
						_netStream.pause();
					}
					break;
				case NetStreamStatus.SEEK_FAILED:
				case NetStreamStatus.SEEK_NOTIFY:
				case NetStreamStatus.SEEK_INVALID_TIME:
					_pendingSeek = false;
					assessBufferSize();
					break;
				case NetStreamStatus.BUFFER_FULL:
					setBuffered(true);
					assessBufferSize();
					break;
				case NetStreamStatus.BUFFER_EMPTY:
					setBuffered(false);
					assessBufferSize();
					break;
			}
		}
		protected function pollVideo():void{
			var total:Number;
			if(!_pendingSeek && _currentTime != _netStream.time){
				_currentTime = _netStream.time;
				if(_currentTimeChanged)_currentTimeChanged.perform(this);
			}
			if(_useTotalForProgress){
				if(!isNaN(_videoStreamProxy.duration)){
					// occasionally bufferLength+time is more that duration
					total = _videoStreamProxy.duration;
					var progress:Number = _netStream.bufferLength+_netStream.time;
					setLoadProps(total>progress?progress:total,total);
				}else{
					setLoadProps(int(_netStream.bytesLoaded+0.5),
						int(_netStream.bytesTotal+0.5));
				}
			}else{
				
				if(_videoStreamProxy.metadataReceived){
					total = (_videoStreamProxy.duration-_netStream.time);
					if(total>_smallBuffer){
						total = _smallBuffer;
					}
				}else{
					total = _smallBuffer;
				}
				if(_buffered || _netStream.bufferLength>total){
					setLoadProps(total,	total);
				}else{
					setLoadProps(_netStream.bufferLength, total);
				}
			}
			// NetStream doesn't dispatch the Buffer Full event when it is paused
			if(_playing && !_streamPlaying && _netStream.bufferLength>=_netStream.bufferTime){
				setBuffered(true);
				_streamPlaying = true;
				_netStream.resume();
				assessBufferSize();
			}
		}
		override public function takeMediaDisplay():ILayoutView{
			_displaysTaken++;
			assessStream();
			return super.takeMediaDisplay();
		}
		override public function returnMediaDisplay(value:ILayoutView):void{
			_displaysTaken--;
			assessStream();
			super.returnMediaDisplay(value);
		}
		override protected function createMediaDisplay():ILayoutView{
			var video:Video = new Video(_displayMeasurements.width,_displayMeasurements.height);
			if(_streamStarted){
				video.attachNetStream(_netStream);
			}
			var videoAsset:IVideoAsset = NativeAssetFactory.getNew(video);
			var display:MediaViewBehaviour = new MediaViewBehaviour(videoAsset,_displayMeasurements);
			display.layoutInfo = new FrameLayoutInfo();
			return display;
		}
		override protected function destroyMediaDisplay(value:ILayoutView):void{
			var display:MediaViewBehaviour = (value as MediaViewBehaviour);
			var video:VideoAsset = display.asset as VideoAsset;
			video.video.attachNetStream(null);
			display.asset = null;
		}
		protected function assessVolume():void{
			if(_streamStarted){
				_netStream.soundTransform = new SoundTransform(_muted && _displaysTaken>0?0:_volume);
			}
		}
		protected function assessBufferSize():void{
			if(_streamStarted){
				var bufLength:Number = _netStream.bufferLength;
				var bufTime:Number;
				
				if(_buffered){
					bufTime = this.largeBuffer;
				}else{
					if(!_playing && _videoStreamProxy.metadataReceived){
						bufTime = this.largeBuffer;
					}else{
						bufTime = this.smallBuffer;
					}
				}
				if(!isNaN(bufTime) && _netStream.bufferTime != bufTime){
					if(bufLength<bufTime){
						setBuffered(false);
					}
					_netStream.bufferTime = (bufLength>bufTime?bufLength:bufTime);
				}
			}
		}
		protected function get largeBuffer(): Number{
			return VideoBufferCalculator.calcLargeBuffer(_videoStreamProxy.duration);
		}
		protected function get smallBuffer(): Number{
			_smallBuffer = VideoBufferCalculator.calcSmallBuffer(_netStream,getTimer()-_loadingStartAt,_loadingByteOffset, _videoStreamProxy.dataRate, _videoStreamProxy.duration);
			return _smallBuffer;
		}
		protected function setBuffered(value:Boolean):void{
			if(_buffered!=value){
				_buffered = value;
				if(_bufferedChanged)_bufferedChanged.perform(this);
			}
		}
		protected function updateDisplayMeasurements(x:Number, y:Number, width:Number, height:Number):void{
			_displayMeasurements.x = x;
			_displayMeasurements.y = y;
			_displayMeasurements.width = width;
			_displayMeasurements.height = height;
			for(var i:* in _allMediaDisplays){
				var view:MediaViewBehaviour = (i as MediaViewBehaviour);
				view.displayMeasurementsChanged();
			}
		}
		protected function onMetadata(from:VideoStreamProxy):void{
			_loadingByteOffset = _netStream.bytesLoaded;
			_loadingStartAt = getTimer();
			updateDisplayMeasurements(0,0,_videoStreamProxy.width,_videoStreamProxy.height);
			assessBufferSize();
			if(!_playing){
				_streamPlaying = false;
				_netStream.pause();
			}
		}
		// TODO: dispatch errors
		protected function onLoadError(e:Event):void{
			//if(_loadFailed)_loadFailed.perform(this);
		}
	}
}
import org.farmcode.acting.actTypes.IAct;
import org.farmcode.acting.acts.Act;
import org.farmcode.math.UnitConversion;

// dynamic to avoid errors from unknown metadata
dynamic class VideoStreamProxy{
	public var width:Number = 320;
	public var height:Number = 240;
	
	public var audioDataRate:Number;
	public var audioCodecId:int;
	public var audioDelay:Number;
	
	public var videoDataRate:Number;
	public var videoCodecId:int;
	
	public var canSeekToEnd:Boolean;
	public var duration:Number;
	public var framerate:int;
	
	public var dataRate:int;
	
	public var metadataReceived:Boolean;
	
	
	/**
	 * handler(from:VideoStreamProxy)
	 */
	public function get metadataChanged():IAct{
		if(!_metadataChanged)_metadataChanged = new Act();
		return _metadataChanged;
	}
	
	protected var _metadataChanged:Act;
	
	public function onMetaData(info:Object):void{
		metadataReceived = true;
		width = info.width;
		height = info.height;
		
		audioDataRate = info.audiodatarate;
		audioCodecId = info.audiocodecid;
		audioDelay = info.audiodelay;
		
		canSeekToEnd = info.canseektoend;
		duration = info.duration;
		framerate = info.framerate;
		
		videoDataRate = info.videodatarate;
		videoCodecId = info.videocodecid;
		
		if(info.keyframes){
			dataRate = 0;
			var lastTime:Number;
			var lastPos:Number;
			for(var i:int=0; i<info.keyframes.times.length; i++){
				var time:Number = info.keyframes.times[i];
				var pos:Number = info.keyframes.filepositions[i];
				if(!isNaN(lastTime) && !isNaN(lastPos)){
					var timeDif:Number = time-lastTime;
					var posDif:Number = pos-lastPos;
					dataRate = Math.max(dataRate,posDif/timeDif);
				}
				lastTime = time;
				lastPos = pos;
			}
			dataRate = UnitConversion.convert(dataRate,UnitConversion.MEMORY_BYTES,UnitConversion.MEMORY_KILOBYTES);
		}else{
			dataRate = videoDataRate+audioDataRate;
		}
		
		if(_metadataChanged)_metadataChanged.perform(this);
	}
	/*
	public function onXMPData(info:Object):void{
	}
	*/
}