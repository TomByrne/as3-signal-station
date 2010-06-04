package au.com.thefarmdigital.structs
{
	import au.com.thefarmdigital.events.VideoEvent;
	import au.com.thefarmdigital.utils.VideoBufferCalculator;
	
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamStatus;
	import flash.utils.getTimer;
	
	import org.farmcode.core.DelayedCall;
	import org.farmcode.math.UnitConversion;
	
	[Event(name="metadataReady", type="au.com.thefarmdigital.events.VideoEvent")]
	[Event(name="cuePointHit", type="au.com.thefarmdigital.events.VideoEvent")]
	[Event(name="playheadChange", type="au.com.thefarmdigital.events.VideoEvent")]
	[Event(name="bufferedChange", type="au.com.thefarmdigital.events.VideoEvent")]
	[Event(name="playStart", type="au.com.thefarmdigital.events.VideoEvent")]
	[Event(name="playStop", type="au.com.thefarmdigital.events.VideoEvent")]
	[Event(name="playingChange", type="au.com.thefarmdigital.events.VideoEvent")]
	/**
	 * The VideoData class is a struct which represents an external video, it can
	 * be used to load and play the external video. It contains buffering logic
	 * which is used to remember the users bitrate and to tailor their buffer
	 * appropriately.
	 */
	public class VideoData extends EventDispatcher
	{
		public function get netStream():NetStream{
			return _netStream;
		}
		public function get playing():Boolean{
			return _playing;
		}
		public function set playing(value:Boolean):void{
			if(value!=_playing){
				_playing = value;
				setBufferSize();
				dispatchEvent(new VideoEvent(VideoEvent.PLAYING_CHANGE));
				assessPoll();
			}
		}
		public function get volume():Number{
			return _netStream.soundTransform.volume;
		}
		public function set volume(value:Number):void{
			var sound:SoundTransform = _netStream.soundTransform;
			sound.volume = value;
			_netStream.soundTransform = sound;
		}
		/**
		 * Can be used to move the playhead to a specific position in the video.
		 * 
		 * @default 0
		 */
		public function get currentTime():Number{
			return _currentTime;
		}
		public function set currentTime(value:Number):void{
			value = Math.min(value,_maxBuffered);
			if(value!=_currentTime){
				_currentTime = value;
    			pendingSeek = true;
				_netStream.seek(_currentTime);
    			if(_maxBuffered==value){
    				setBufferSize();
    			}
	    		dispatchEvent(new VideoEvent(VideoEvent.PLAYHEAD_CHANGE));
			}
		}
		public function get bufferLength():Number{
			return _bufferLength;
		}
		public function get totalTime():Number{
			return _totalTime;
		}
		public function get videoWidth():Number{
			return _videoWidth;
		}
		public function get videoHeight():Number{
			return _videoHeight;
		}
		public function get framerate():Number{
			return _framerate;
		}
		
		public function set repeatCount(repeatCount: int): void
		{
			if (repeatCount != this._repeatCount)
			{
				this._repeatCount = repeatCount;
			}
		}
		public function get repeatCount(): int
		{
			return this._repeatCount;
		}
		public function get numPlays(): uint
		{
			return this._numPlays;
		}
		/**
		 * Indicates whether the entire video has loaded.
		 */
		public function get buffered():Boolean{
			return _buffered;
		}
		
		
		public var autoRewind:Boolean = true;
		public var url:String;
		private var _playing:Boolean = true;
		private var _currentTime:Number;
		private var _bufferLength:Number;
		/* It takes the NetStream some time to recalculate it's bufferLength
			after seek() has been called. So we record it's maximum loaded buffer time.
		*/
		private var _maxBuffered:Number;
		private var _completelyLoaded:Boolean = false;
		private var _connected:Boolean = false;
		private var _buffered:Boolean = false;
		private var pendingSeek:Boolean = false;
		
		// Metadata
		private var _totalTime:Number;
		private var _videoWidth:Number;
		private var _videoHeight:Number;
		private var _framerate:Number;
		
		private var loadingStartAt:Number;
		private var loadingByteOffset:Number;
		protected var _netStream:NetStream;
		protected var _connection:NetConnection;
		protected var pollCall:DelayedCall;
		protected var _repeatCount: int;
		protected var _numPlays: uint;
		protected var _dataRate:Number; // datarate for video and audio as proposed by the metadata (in bytes)
		
		protected var _videoSettingsIdentifier: String;
		protected var _videoSettingsPath: String;
		
		protected var _streamClient:Object; // we need to create a proxy as some encoders include additional method calls.
		
		protected var _netStreamPlaying: Boolean;
		
		protected var pendingStart:Boolean = false;
		
		
		public function VideoData(url:String=null, server:String = null){
			_streamClient = {};
			_streamClient.onMetaData = function(info:Object):void{
				onMetaData(info);
			}
			
			this._netStreamPlaying = false;
			this._repeatCount = 0;
			this._numPlays = 0;
			this.url = url;
			
			_connection = this.createNetConnection();
            
            if (server)
            {
            	_connection.connect(server);
            	_connection.client = this.createCustomClient();
            }
            else
            {	
            	_connection.connect(null);
            }	
            
            createNetStream();            
		}
		
		protected function createNetConnection(): NetConnection{
			return new NetConnection();
		}
		
		protected function createCustomClient(): Object{
			return null;
		}
		
		protected function createNetStream():void{
            _netStream = new NetStream(_connection);
            _netStream.client = _streamClient;
            _netStream.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
		}
		
		protected function resetNumPlays(): void
		{
			this._numPlays = 0;
		}
		
		public function load():void {
			if(_connected)unload();
			if(url){
				_currentTime = NaN;
				pendingStart = true;
				this._numPlays = 0;
				_currentTime = 0;
				_maxBuffered = 0;
				loadingStartAt = NaN;
				this._netStreamPlaying = true;
				_netStream.play(url);
			}else{
				throw new Error("VideoView.load(): can't call load before setting the url.");
			}
		}
		public function unload():void {
			if (_netStream)
			{
				_netStream.close();
				this._netStreamPlaying = false;
			}
			if (this._connection)
			{
				createNetStream();
				this._netStreamPlaying = false;
			}
            _maxBuffered = NaN;
			_completelyLoaded = _connected = false;
			setBuffered(false)
			assessPoll();
		}
		
		public function dispose(): void
		{
            _netStream.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
            
            _netStream.close();
            _connection.close();
            
            _connection = null;
            _netStream = null;
            
            _maxBuffered = NaN;
            
            if (this.pollCall)
            {
            	this.pollCall.clear();
            	this.pollCall = null;
            }
		}
		
		/**
		 * Called internally by the NetConnection
		 * 
		 * @private
		 */
		private function onMetaData(info:Object):void {
			if(info.keyframes){
				_dataRate = 0;
				var lastTime:Number;
				var lastPos:Number;
				for(var i:int=0; i<info.keyframes.times.length; i++){
					var time:Number = info.keyframes.times[i];
					var pos:Number = info.keyframes.filepositions[i];
					if(!isNaN(lastTime) && !isNaN(lastPos)){
						var timeDif:Number = time-lastTime;
						var posDif:Number = pos-lastPos;
						_dataRate = Math.max(_dataRate,posDif/timeDif);
					}
					lastTime = time;
					lastPos = pos;
				}
				_dataRate = UnitConversion.convert(_dataRate,UnitConversion.MEMORY_BYTES,UnitConversion.MEMORY_KILOBYTES);
			}else{
				_dataRate = info.videodatarate+info.audiodatarate;
			}
			_totalTime = info.duration;
			_videoWidth = info.width;
			_videoHeight = info.height;
			_framerate = info.framerate;
			loadingStartAt = getTimer();
			loadingByteOffset = _netStream.bytesLoaded;
			setBufferSize();
			if(_playing){
				this.netStreamPlaying = true;
			}
			dispatchEvent(new VideoEvent(VideoEvent.METADATA_READY));
	    }
		/**
		 * Called internally by the NetConnection
		 * 
		 * @private
		 */
	    public function onCuePoint(info:Object):void {
			dispatchEvent(new VideoEvent(VideoEvent.CUE_POINT_HIT,false,false,info));
	    }
	    protected function onIOError(e:IOErrorEvent):void{
			dispatchEvent(e);
	    }
	    protected function assessPoll():void{
	    	var shouldPoll:Boolean = (_connected && (_playing || _netStream.bytesLoaded<_netStream.bytesTotal || !_netStream.bytesTotal));
			if(pollCall && !shouldPoll){
				pollCall.clear();
				pollCall = null;
			}else if(shouldPoll && !pollCall){
				pollCall = new DelayedCall(poll,1,false,null,0);
				pollCall.begin();
			}
	    }
	    protected function poll():void{
	    	if(!pendingSeek){ 
	    		_currentTime = _netStream.time;
	    		if (!this.netStreamPlaying)
	    		{
	    			setBufferSize();
	    		}	    			    		
	    	}else if(_netStream.bufferLength>_netStream.bufferTime){
	    		// sometimes netStream.seek gets stuck (if you go right to the edge of the buffer)
	    		pendingSeek = false;	
	    		setBufferSize();
	    	}
	    	_bufferLength = _netStream.bufferLength;
	    	_maxBuffered = Math.max(netStream.time+_netStream.bufferLength,_maxBuffered);

	    	dispatchEvent(new VideoEvent(VideoEvent.PLAYHEAD_CHANGE));
	    }
	    protected function onNetStatus(e:NetStatusEvent):void{
	    	switch(e.info.code){
	    		case NetStreamStatus.BUFFER_EMPTY:
	    			setBufferSize();
    				if(!playing)
    				{
    					this.netStreamPlaying = false;
    				}
    				this.assessPoll();
	    			break;
	    		case NetStreamStatus.BUFFER_FULL:
	    			this._netStreamPlaying = true;
	    			if(!isNaN(_totalTime) && _netStream.bufferTime>=_totalTime){
	    				_completelyLoaded = true;
	    			}
	    			setBufferSize();
    				if(!playing)
    				{
    					this.netStreamPlaying = false;
    				}
    				this.assessPoll();
	    			break;
	    		case NetStreamStatus.BUFFER_FLUSH:
	    			setBufferSize();
					assessPoll();
	    			break;
	    		case NetStreamStatus.PLAY_START:
	    			this._netStreamPlaying = true;
	    			if(!isNaN(_totalTime)){
	    				setBufferSize();
	    			}else{
	    				this.netStreamPlaying = false; // first time through pause it and wait for metadata
	    			}
	    			
	    			if(pendingStart){
	    				if(!playing){
	    					this.netStreamPlaying = false;
	    				}
	    				if(_currentTime){
	    					pendingSeek = true;
	    					_netStream.seek(_currentTime);
	    				}
	    				_connected = true;
	    				pendingStart = false;
	    				assessPoll();
	    			}
	    			if(_completelyLoaded){
		    			if(playing)dispatchEvent(new VideoEvent(VideoEvent.PLAY_START));
	    			}
	    			break;
	    		case NetStreamStatus.PLAY_STOP:	
	    			this._netStreamPlaying = false;
	    			playing = false;
	    			if(autoRewind){
	    				currentTime = 0;
	    			}
	    			this._numPlays++;
	    			if (this.repeatCount < 0 || this.numPlays < this.repeatCount) {
	    				if(!autoRewind){
	    					currentTime = 0;
	    				}
	    				this.playing = true;
	    			}
	    			dispatchEvent(new VideoEvent(VideoEvent.PLAY_STOP));
	    			break;
	    		case NetStreamStatus.SEEK_NOTIFY:
	    			setBufferSize();
	    			//pendingSeek = false;
	    			if(!playing){
	    				dispatchEvent(new VideoEvent(VideoEvent.PLAYHEAD_CHANGE));
	    			}
	    			break;
	    	}
	    }
	    
	    protected function get largeBuffer(): Number
	    {
	    	return VideoBufferCalculator.calcLargeBuffer(_totalTime);
	    }
	    
	    protected function get smallBuffer(): Number
	    {
	    	return VideoBufferCalculator.calcSmallBuffer(_netStream,getTimer()-loadingStartAt,loadingByteOffset,_dataRate, _totalTime);
	    }
	    
	    protected function setBufferSize():void{
	    	if(_netStream){
		    	var bufTime:Number = 0;
				if(isBuffered && _playing){
					bufTime = this.largeBuffer;
				} else {
					bufTime = this.smallBuffer;
				}
				
				var isBuffered:Boolean = (bufTime<=_netStream.bufferLength || _netStream.bytesLoaded>=_netStream.bytesTotal);
				if(_netStream.bufferTime != bufTime){
					_netStream.bufferTime = Math.max(_netStream.bufferLength, bufTime);
				}
				setBuffered(isBuffered);
	    	}
	    }
	    protected function setBuffered(value:Boolean):void{
	    	
	    	this.netStreamPlaying = this._playing && value;
	    	
	    	if(_buffered!=value){
	    		_buffered = value;
		    	dispatchEvent(new VideoEvent(VideoEvent.BUFFERED_CHANGE));
	    	}
	    }
	    
	    protected function set netStreamPlaying(value: Boolean): void
	    {
	    	if (value != this.netStreamPlaying)
	    	{
	    		this._netStreamPlaying = value;
	    		
	    		if (this._netStream)
	    		{
		    		if (this.netStreamPlaying)
		    		{
		    			this._netStream.resume();
		    		}
		    		else
		    		{
		    			this._netStream.pause();
		    		}
		    		dispatchEvent(new VideoEvent(VideoEvent.PLAYING_CHANGE));
		    	}
	    	}
	    }
	    protected function get netStreamPlaying(): Boolean
	    {
	    	return this._netStreamPlaying;
	    }
	}
}
