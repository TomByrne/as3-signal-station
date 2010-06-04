package au.com.thefarmdigital.display.controls
{
	import au.com.thefarmdigital.events.VideoEvent;
	import au.com.thefarmdigital.structs.VideoData;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import org.farmcode.display.constants.Direction;
	
	public class BufferSlider extends Slider
	{
		public function get videoData():VideoData{
			return _videoData;
		}
		public function set videoData(value:VideoData):void{
			if(_videoData!=value){
				_videoData=value;
				_videoData.addEventListener(VideoEvent.PLAYHEAD_CHANGE,onPlayheadChange);
				onPlayheadChange();
			}
		}
		public function get bufferedBacking():DisplayObject{
			return _bufferedBacking;
		}
		public function set bufferedBacking(to:DisplayObject):void{
			if(_bufferedBacking != to){
				if(to.parent && to.parent!=this)to.parent.removeChild(to);
				if(!to.parent)addChild(to);
				_bufferedBacking = to;
				invalidate();
			}
		}
		public function get playedBacking():DisplayObject{
			return _playedBacking;
		}
		public function set playedBacking(to:DisplayObject):void{
			if(_playedBacking != to){
				if(to.parent && to.parent!=this)to.parent.removeChild(to);
				if(!to.parent)addChild(to);
				_playedBacking = to;
				invalidate();
			}
		}
		
		protected var _videoData:VideoData;
		protected var _bufferedBacking:DisplayObject;
		protected var _playedBacking:DisplayObject;
		protected var _scrubbing:Boolean = false;
		protected var _playingBeforeScrub:Boolean = false;
		protected var _bufferedValue:Number = 0;
		
		protected function onPlayheadChange(e:VideoEvent=null):void{
			if(!_scrubbing)value = _videoData.currentTime/_videoData.totalTime;
			var oldBuffValue:Number = _bufferedValue;
			_bufferedValue = Math.min(Math.max(_videoData.netStream.bytesLoaded/_videoData.netStream.bytesTotal,0),1);
			validate(oldBuffValue!=_bufferedValue);
		}
		override protected function mouseDownHandler(e:MouseEvent):void{
			if (_videoData) {
				_playingBeforeScrub = _videoData.playing
				_videoData.playing = false;
			} else {
				_playingBeforeScrub = false;
			}
			super.mouseDownHandler(e);
			_scrubbing = true;
		}
		override protected function mouseUpHandler(e:MouseEvent):void{
			super.mouseUpHandler(e);
			_scrubbing = false;
			if (_videoData) {
				_videoData.playing = _playingBeforeScrub;
			}
		}
		override protected function setValue(to:Number):void{
			super.setValue(to);
			if (_videoData) {
				_videoData.currentTime = _videoData.totalTime*to;
			}
		}
		override protected function draw():void{
			super.draw();
			if(_direction==Direction.VERTICAL){
				var maxSize:Number = Math.max(_backing.width,_thumb?_thumb.width:0);
				var range:Number = _backing.height-_paddingFore-_paddingAft;
				if(_playedBacking){
					_playedBacking.y = 0;
					_playedBacking.x = (maxSize-_playedBacking.width)/2;
					_playedBacking.height = _paddingFore+(range*_drawValue);
				}
				if(_bufferedBacking){
					_bufferedBacking.y = 0;
					_bufferedBacking.x = (maxSize-_bufferedBacking.width)/2;
					_bufferedBacking.height = _paddingFore+(range*_bufferedValue);
				}
			}else{
				maxSize = Math.max(_backing.height,_thumb?_thumb.height:0);
				range = _backing.width-_paddingFore-_paddingAft;
				if(_playedBacking){
					_playedBacking.x = 0;
					_playedBacking.y = (maxSize-_playedBacking.height)/2;
					_playedBacking.width = _paddingFore+(range*_drawValue);
				}
				if(_bufferedBacking){
					_bufferedBacking.x = 0;
					_bufferedBacking.y = (maxSize-_bufferedBacking.height)/2;
					_bufferedBacking.width = _paddingFore+(range*_bufferedValue);
				}
			}
		}
	}
}