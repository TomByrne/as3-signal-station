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
				assessConnection();
			}
		}
		
		
		public function get videoId():String{
			return _videoId;
		}
		public function set videoId(value:String):void{
			if(_videoId!=value){
				closeStream();
				_videoId = value;
				assessStream();
			}
		}
		
		
		
		private var _hostUrl:String;
		private var _videoId:String;
		private var _connectionStarted:Boolean;
		private var _connected:Boolean;
		
		protected var _netConnection:OvpConnection;
		
		public function StreamingVideoSource(hostUrl:String=null, videoId:String=null){
			super();
			createNetConnection();
			this.hostUrl = hostUrl;
			this.videoId = videoId;
		}
		protected function createNetConnection():void{
			if(!_netConnection){
				_netConnection = new OvpConnection();
				_netConnection.addEventListener(OvpEvent.ERROR, onLoadError);
				_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
			}
		}
		protected function closeConnection():void{
			closeStream();
			if(_connectionStarted){
				_connectionStarted = false;
				_netConnection.close();
				_connected = false;
			}
		}
		protected function assessConnection():void{
			if(!_connectionStarted && _hostUrl){
				_connectionStarted = true;
				_netConnection.connect(_hostUrl);
			}
		}
		override protected function assessStream():void{
			createNetConnection();
			super.assessStream();
		}
		override protected function createNetStream():NetStream{
			if(_connected && _videoId){
				var stream:OvpNetStream = new OvpNetStream(_netConnection);
				stream.play(_videoId);
				return stream;
			}
			return null;
		}
		protected function onConnectionStatus(e:NetStatusEvent):void{
			switch(e.info.code){
				case NetConnectionCodes.CONNECT_SUCCESS:
					_connected = true;
					assessStream();
					break;
				case NetConnectionCodes.CONNECT_REJECTED:
					_connectionStarted = false;
					Log.error( "StreamingVideoSource.onConnectionStatus: connect rejected by server; "+e.info.description);
					break;
			}
		}
	}
}