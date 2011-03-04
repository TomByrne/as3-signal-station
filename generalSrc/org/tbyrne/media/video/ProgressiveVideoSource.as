package org.tbyrne.media.video
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	
	/**
	 * ProgressiveVideoSource is used to create Video displays from a static video
	 * file source.
	 * 
	 * Note on NetStream:
	 * If netstream is paused before metadata is received, it will not come through
	 * until the entire file is downloaded.
	 */
	public class ProgressiveVideoSource extends AbstractVideoSource
	{
		
		public function get videoUrl():String{
			return _videoUrl;
		}
		public function set videoUrl(value:String):void{
			if(_videoUrl!=value){
				stopNetStream();
				_videoUrl = value;
				assessConnection();
			}
		}
		
		protected var _videoUrl:String;
		protected var _netConnection:NetConnection;
		
		public function ProgressiveVideoSource(videoUrl:String=null){
			super();
			this.videoUrl = videoUrl;
		}
		override protected function connect():Boolean{
			if(!_netConnection){
				_netConnection = new NetConnection();
				_netConnection.connect(null);
			}
			return true;
		}
		override protected function startStream():NetStream{
			if(_videoUrl){
				var stream:NetStream = new NetStream(_netConnection);
				stream.play(_videoUrl);
				return stream;
			}
			return null;
		}
	}
}