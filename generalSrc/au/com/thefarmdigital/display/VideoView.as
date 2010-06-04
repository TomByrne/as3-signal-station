package au.com.thefarmdigital.display
{
	import au.com.thefarmdigital.events.VideoEvent;
	import au.com.thefarmdigital.structs.VideoData;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import org.farmcode.core.DelayedCall;
	
	/** The VideoView class is a subclass of the MediaView class which allows for specific scaling, alignment & skinning of the loaded video.
	 * Note the the VideoView class will pause it's VideoData when removed from the stage.
	 */
	public class VideoView extends MediaView
	{
		public function get videoData():VideoData{
			return _videoData;
		}
		public function set videoData(value:VideoData):void{
			if(_videoData!=value){
				if(_videoData){
					_videoData.unload();
					_videoData.removeEventListener(VideoEvent.PLAY_START,eventInvalidate);
					_videoData.removeEventListener(VideoEvent.BUFFERED_CHANGE,eventInvalidate);
					_videoData.removeEventListener(VideoEvent.METADATA_READY,onMetaData);
					if(video)video.clear();
				}
				_videoData = value;
				if(_videoPoller){
					_videoPoller.clear();
				}
				if(_videoData){
					_videoData.addEventListener(VideoEvent.PLAY_START,eventInvalidate);
					_videoData.addEventListener(VideoEvent.BUFFERED_CHANGE,eventInvalidate);
					_videoData.addEventListener(VideoEvent.METADATA_READY,onMetaData);
					if(video)video.attachNetStream(_videoData.netStream);
				}
				invalidate();
			}
		}
		public function get video():Video{
			return (_media as Video);
		}
		public function set video(value:Video):void{
			if(_media!=value){
				_media = value;
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if(!value.parent)addChild(value);
				if(_videoData)video.attachNetStream(_videoData.netStream);
				depthsInvalid = true;
				invalidate();
			}
		}
		
		[Inspectable(defaultValue=true, type="Boolean", name="Show Video While Buffering")]
		public function get showVideoWhileBuffering():Boolean{
			return _showVideoWhileBuffering;
		}
		public function set showVideoWhileBuffering(value:Boolean):void{
			if(_showVideoWhileBuffering!=value){
				_showVideoWhileBuffering = value;
				invalidate();
			}
		}
		
		protected var _showVideoWhileBuffering:Boolean = true;
		protected var _videoData:VideoData;
		protected var _wasPlayingOnStage:Boolean;
		protected var _video:Video;
		protected var _videoPoller:DelayedCall;
		
		public function VideoView(){
			super();
			var frame:DisplayObject = (_frameBackground?_frameBackground:_frameForeground);
			if(_media){
				if(frame)_padding = new Rectangle(_media.x-frame.x,_media.y-frame.y,(_media.x+_media.width)-(frame.x+frame.width),(_media.y+_media.height)-(frame.y+frame.height));
			}else{
				_video = new Video();
				_media =_video;
				addChild(_media);
			}
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		protected function onMetaData(e:Event):void{
			if(_videoData.videoWidth || _video.videoWidth){
				eventInvalidate();
			}else{
				if(!_videoPoller){
					_videoPoller = new DelayedCall(onPollVideo,1,false,null,0);
				}
				_videoPoller.begin();
			}
		}
		protected function onPollVideo():void{
			if(_video.videoWidth){
				_videoPoller.clear();
				eventInvalidate();
			}
		}
		protected function onAdded(e:Event):void{
			if(_wasPlayingOnStage){
				_wasPlayingOnStage = false;
				videoData.playing = true;
			}
		}
		protected function onRemoved(e:Event):void{
			if(videoData && videoData.playing){
				_wasPlayingOnStage = true;
				videoData.playing = false;
			}
		}
		override protected function draw():void{
			super.draw()
			_media.visible = ((_videoData && _videoData.buffered)||_showVideoWhileBuffering);
		}
		override protected function mediaLoaded():Boolean{
			return (videoData?videoData.buffered:false);
		}
		override protected function getMediaDimensions():Rectangle{
			if(_videoData){
				var height:Number = _videoData.videoHeight?_videoData.videoHeight:_video.videoHeight;
				var width:Number = _videoData.videoWidth?_videoData.videoWidth:_video.videoWidth;
				return new Rectangle(0,0,width,height);
			}else{
				return new Rectangle();
			}
		}
		override protected function showLoadIndicator():Boolean{
			return (videoData && _media && !mediaLoaded());
		}
	}
}