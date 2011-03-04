package org.tbyrne.media.video
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnectionCodes;
	import flash.net.NetStream;
	
	import org.openvideoplayer.events.OvpEvent;
	import org.openvideoplayer.net.OvpConnection;
	import org.openvideoplayer.net.OvpNetStream;
	
	
	/**
	 * ProgressiveVideoSource is used to create Video displays from a static video
	 * file source.
	 * 
	 * Note on NetStream:
	 * If netstream is paused before metadata is received, it will not come through
	 * until the entire file is downloaded.
	 */
	public class StreamingVideoSource extends AbstractVideoSource
	{
		public function get hostUrl():String{
			return _hostUrl;
		}
		public function set hostUrl(value:String):void{
			if(_hostUrl!=value){
				closeConnection();
				_hostUrl = value;
				
				if(_hostUrl){
					var protocol:int = _hostUrl.indexOf("://");
					if(protocol){
						_safeHostUrl = _hostUrl.slice(protocol+3);
					}
				}else{
					_safeHostUrl = null;
				}
				var lastSlash:int = _safeHostUrl.lastIndexOf("/");
				var lastDot:int = _safeHostUrl.lastIndexOf(".");
				if(lastDot!=-1 && lastSlash!=-1 && lastSlash<lastDot){
					_assumedVideoId = _safeHostUrl.slice(lastSlash+1);
					_safeHostUrl = _safeHostUrl.substr(0,lastSlash);
				}
				assessConnection();
			}
		}
		
		
		public function get videoId():String{
			return _videoId;
		}
		public function set videoId(value:String):void{
			if(_videoId!=value){
				stopNetStream();
				_videoId = value;
				assessConnection();
			}
		}
		
		
		
		private var _hostUrl:String;
		private var _safeHostUrl:String;
		private var _assumedVideoId:String;
		private var _videoId:String;
		private var _connectionStarted:Boolean;
		
		protected var _netConnection:OvpConnection;
		
		public function StreamingVideoSource(hostUrl:String=null, videoId:String=null){
			super();
			this.hostUrl = hostUrl;
			this.videoId = videoId;
		}
		protected function closeConnection():void{
			stopNetStream();
			if(_connectionStarted){
				_connectionStarted = false;
				_netConnection.close();
				_connected = false;
			}
		}
		override protected function connect():Boolean{
			if(!_netConnection){
				_netConnection = new OvpConnection();
				_netConnection.addEventListener(OvpEvent.ERROR, onLoadError);
				_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
			}
			if(!_connectionStarted && _safeHostUrl){
				_connectionStarted = true;
				_netConnection.connect(_safeHostUrl);
			}
			return false;
		}
		override protected function startStream():NetStream{
			var vidId:String = _videoId || _assumedVideoId;
			if(_connected && vidId){
				var stream:OvpNetStream = new OvpNetStream(_netConnection);
				stream.play(vidId);
				return stream;
			}
			return null;
		}
		protected function onConnectionStatus(e:NetStatusEvent):void{
			switch(e.info.code){
				case NetConnectionCodes.CONNECT_SUCCESS:
					_connected = true;
					assessNetStream();
					break;
				case NetConnectionCodes.CONNECT_REJECTED:
					_connectionStarted = false;
					Log.log(Log.EXT_ERROR, "StreamingVideoSource.onConnectionStatus: connect rejected by server; "+e.info.description);
					break;
			}
		}
	}
}