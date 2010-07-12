package org.farmcode.sound.soundControls
{
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	import flash.net.NetStreamCodes;
	
	public class NetStreamSoundControl extends AbstractSoundControl
	{
		public function get netStream():NetStream{
			return _netStream;
		}
		public function set netStream(value:NetStream):void{
			if(_netStream != value){
				_netStream = value;
				_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				applyVolume();
			}
		}
		
		private var _netStream:NetStream;
		private var _isPlaying:Boolean;
		private var _shouldBePlaying:Boolean;
		
		public function NetStreamSoundControl(netStream:NetStream=null, allowOthers:Boolean=false){
			super();
			this.netStream = netStream;
			this.allowOthers = allowOthers;
			this.allowQueueInterrupt = false;
			this.allowQueuePostpone = false;
		}
		
		override public function play():void{
			_shouldBePlaying = true;
			if(_isPlaying){
				dispatchBegun();
			}
		}
		
		override public function stop():void{
			_shouldBePlaying = false;
			if(!_isPlaying){
				dispatchFinished();
			}
		}
		override protected function applyVolume(): void{
			if(_netStream){
				_netStream.soundTransform = compileTransform();
			}
		}
		protected function onNetStatus(e:NetStatusEvent):void{
	    	switch(e.info.code){
	    		case NetStreamCodes.PLAY_START:
	    			_isPlaying = true;
	    			if(_shouldBePlaying){
	    				dispatchBegun();
	    			}
	    			break;
	    		case NetStreamCodes.PLAY_STOP:
	    			_isPlaying = false;
	    			if(!_shouldBePlaying){
	    				dispatchFinished();
	    			}
	    			break;
	    	}
		}
	}
}