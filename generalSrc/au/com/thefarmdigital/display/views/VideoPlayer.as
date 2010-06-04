package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.VideoView;
	import au.com.thefarmdigital.display.controls.BufferSlider;
	import au.com.thefarmdigital.display.controls.CustomButton;
	import au.com.thefarmdigital.display.controls.Slider;
	import au.com.thefarmdigital.events.ControlEvent;
	import au.com.thefarmdigital.events.VideoEvent;
	import au.com.thefarmdigital.structs.VideoData;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	
	import org.farmcode.display.constants.Direction;
	
	public class VideoPlayer extends StackView
	{
		public static const DEFAULT_SETTINGS_IDENTIFIER: String = "farm.videoSettings";
		public static const DEFAULT_SETTINGS_PATH: String = "/";
		
		public function get videoView():VideoView{
			return _videoView;
		}
		public function set videoView(value:VideoView):void{
			if(_videoView!=value){
				_videoView = value;
				if(_videoData)_videoView.videoData = _videoData;
				invalidate();
			}
		}
		public function get videoData():VideoData{
			return _videoData;
		}
		public function set videoData(value:VideoData):void{
			if(_videoData!=value){
				_videoData = value;
				if(_videoData){
					_videoData.addEventListener(VideoEvent.PLAY_STOP,onPlayChange);
					_videoData.volume = sharedObject.data.volume;
					if(_videoView)_videoView.videoData = value;
					if(_playPauseButton)_playPauseButton.selected = !_videoData.playing;
					if(_volumeSlider)_volumeSlider.value = _videoData.volume
					if(_bufferSlider)_bufferSlider.videoData = _videoData;
					if(_muteButton)_muteButton.selected = (_videoData.volume==0);
					invalidate();
				}
			}
		}
		public function get playPauseButton():CustomButton{
			return _playPauseButton;
		}
		public function set playPauseButton(value:CustomButton):void{
			if(_playPauseButton!=value){
				if(_playPauseButton)_playPauseButton.removeEventListener(MouseEvent.CLICK,onPlayPauseClick);
				_playPauseButton = value;
				_playPauseButton.autoToggleSelect = true;
				_playPauseButton.addEventListener(MouseEvent.CLICK,onPlayPauseClick);
				if(_videoData){
					_playPauseButton.selected = !_videoData.playing;
				} else {
					_playPauseButton.selected = true;
				}
				if(container){
					if(value.parent!=container)value.parent.removeChild(value);
					if(!value.parent)container.addChild(value);
				}
				invalidate();
			}
		}
		public function get muteButton():CustomButton{
			return _muteButton;
		}
		public function set muteButton(value:CustomButton):void{
			if (_muteButton != value) {
				if(_muteButton)_muteButton.removeEventListener(MouseEvent.CLICK,onMuteClick);
				_muteButton = value;
				_muteButton.autoToggleSelect = true;
				_muteButton.addEventListener(MouseEvent.CLICK,onMuteClick);
				if(container){
					if(value.parent!=container)value.parent.removeChild(value);
					if(!value.parent)container.addChild(value);
				}
				invalidate();
			}
		}
		public function get stopButton():CustomButton{
			return _stopButton;
		}
		public function set stopButton(value:CustomButton):void{
			if(_stopButton!=value){
				_stopButton = value;
				_stopButton.addEventListener(MouseEvent.CLICK,onStopClick);
				if(container){
					if(value.parent!=container)value.parent.removeChild(value);
					if(!value.parent)container.addChild(value);
				}
				invalidate();
			}
		}
		public function get restartButton():CustomButton{
			return _restartButton;
		}
		public function set restartButton(value:CustomButton):void{
			if(_restartButton!=value){
				_restartButton = value;
				_restartButton.addEventListener(MouseEvent.CLICK,onRestartClick);
				if(container){
					if(value.parent!=container)value.parent.removeChild(value);
					if(!value.parent)container.addChild(value);
				}
				invalidate();
			}
		}
		public function get volumeSlider():Slider{
			return _volumeSlider;
		}
		public function set volumeSlider(value:Slider):void{
			if(_volumeSlider!=value){
				_volumeSlider = value;
				_volumeSlider.immediateValueUpdate = true;
				if(container){
					if(value.parent!=container)value.parent.removeChild(value);
					if(!value.parent)container.addChild(value);
				}
				if(_videoData)_volumeSlider.value = _videoData.volume;
				_volumeSlider.addEventListener(ControlEvent.VALUE_CHANGE, onVolumeChange);
				invalidate();
			}
		}
		public function get bufferSlider():BufferSlider{
			return _bufferSlider;
		}
		public function set bufferSlider(value:BufferSlider):void{
			if(_bufferSlider!=value){
				_bufferSlider = value;
				if(container){
					if(value.parent!=container)value.parent.removeChild(value);
					if(!value.parent)container.addChild(value);
				}
				_bufferSlider.immediateValueUpdate = true;
				if(_videoData)_bufferSlider.videoData = _videoData;
				invalidate();
			}
		}
		/**
		 * Whether the controls will be overlayed on top of the video as opposed to below
		 */
		public function get overlayControls():Boolean{
			return _overlayControls;
		}
		public function set overlayControls(value:Boolean):void{
			if(_overlayControls!=value){
				var backBelow:Boolean = getChildIndex(stateContainer)<getChildIndex(videoView);
				if ((backBelow && value) || (!backBelow && !value)){
					swapChildren(stateContainer,videoView);
				}
				_overlayControls = value;
				invalidate();
			}
		}
		
		public function set videoSettingsIdentifier(videoSettingsIdentifier: String): void
		{
			if (this._videoSettingsIdentifier != videoSettingsIdentifier)
			{
				this._videoSettingsIdentifier = videoSettingsIdentifier;
				this.instantiateSharedData();
			}
		}
		public function get videoSettingsIdentifier(): String
		{
			return this._videoSettingsIdentifier;
		}
		
		public function set videoSettingsPath(videoSettingsPath: String): void
		{
			if (this._videoSettingsPath != videoSettingsPath)
			{
				this._videoSettingsPath = videoSettingsPath;
				this.instantiateSharedData();
			}
		}
		public function get videoSettingsPath(): String
		{
			return this._videoSettingsPath;
		}
		public function set videoControlsGap(value: Number): void
		{
			if (this._videoControlsGap != value)
			{
				this._videoControlsGap = value;
				this.invalidate();
			}
		}
		public function get videoControlsGap(): Number
		{
			return this._videoControlsGap;
		}
		
		protected var _videoControlsGap:Number = 0;
		protected var _videoView:VideoView;
		protected var _videoData:VideoData;
		
		// Controls
		protected var _overlayControls:Boolean = false;
		protected var _playPauseButton:CustomButton;
		protected var _stopButton:CustomButton;
		protected var _restartButton:CustomButton;
		protected var _muteButton:CustomButton;
		//protected var _fullScreenButton:CustomButton;
		protected var _volumeSlider:Slider;
		protected var _bufferSlider:BufferSlider;
		//protected var _detailsLabel:Label;
		protected var sharedObject:SharedObject;
		protected var _videoSettingsIdentifier: String;
		protected var _videoSettingsPath: String;
		
		public function VideoPlayer(){
			super();
			
			this._videoSettingsIdentifier = VideoPlayer.DEFAULT_SETTINGS_IDENTIFIER;
			this._videoSettingsPath = VideoPlayer.DEFAULT_SETTINGS_PATH;
			
			this.instantiateSharedData();
		}
		
		protected function instantiateSharedData(): void
		{
			this.sharedObject = SharedObject.getLocal(this._videoSettingsIdentifier, _videoSettingsPath);
			if (sharedObject.data.volume==null)sharedObject.data.volume = 1;
			// TODO: Save current settings to new from old (if relevant)
			// TODO: Should this be synced with the VideoData sharedobject which has shareddata storage also
		}
		
		protected function onMuteClick(event: MouseEvent): void {
			if (_muteButton.selected) {
				_videoData.volume = 0;
			}else{
				if(_volumeSlider.value){
					_videoData.volume = _volumeSlider.value;
				}else{
					_videoData.volume = _volumeSlider.value = 0.5;
				}
			}
		}
		
		protected function onStopClick(event: MouseEvent): void {
			_videoData.playing = false;
			_playPauseButton.selected = true;
		}
		protected function onPlayPauseClick(e:MouseEvent):void{
			if(_videoData)_videoData.playing = !_playPauseButton.selected;
		}
		protected function onRestartClick(e:MouseEvent):void{			
			if (_videoData) {			
				_videoData.currentTime = 0;
				_videoData.playing = true;				
				_playPauseButton.selected = false;
			}
		}
		protected function onVolumeChange(e:ControlEvent):void{
			if(_videoData)_videoData.volume = _volumeSlider.value;
			sharedObject.data.volume = _volumeSlider.value;
			if(_muteButton)_muteButton.selected = (_volumeSlider.value==0);
		}
		protected function onPlayChange(e:VideoEvent):void{
			if (_videoData) {		
				_playPauseButton.selected = !_videoData.playing;
			}
		}
		override protected function draw():void{
			if(_bufferSlider && _bufferSlider.direction==direction){
				var prop:String = (_direction==Direction.VERTICAL?"height":"width");
				var stack:Number = 0;
				var length:int = container.numChildren;
				for(var i:int=0; i<length; ++i){
					var child:DisplayObject = container.getChildAt(i);
					if(child!=_bufferSlider)stack += (child[prop])+gap;
				}
				if(_direction==Direction.VERTICAL){
					_bufferSlider.height = height-_topPadding-_bottomPadding-stack-gap;
				}else{
					_bufferSlider.width = width-_leftPadding-_rightPadding-stack-gap;
				}
			}
			super.draw();
			_videoView.x = 0;
			_videoView.y = 0;
			if(direction==Direction.VERTICAL){
				_videoView.width = width-super.measuredWidth-leftPadding-rightPadding;
				_videoView.height = height;
				container.x = _videoView.width+leftPadding+_videoControlsGap;
				container.scrollRect = _maskContents?new Rectangle(0, 0, width - _leftPadding - _rightPadding, height - _topPadding - _bottomPadding):null;
			}else{
				_videoView.x = _leftPadding;
				_videoView.y = _topPadding;
				_videoView.width = width - _leftPadding - _rightPadding;

				var videoHeight: Number = height;
				if (_overlayControls) {
					videoHeight -= (_topPadding + _bottomPadding);
					container.y = height-_bottomPadding;					
					if (_backing) {
						_backing.scaleY = 1;
						_backing.y = videoHeight - _backing.height;
						container.y -= _backing.height;					
					}
				}else{
					videoHeight -= (super.measuredHeight + _topPadding + _bottomPadding + _videoControlsGap);
					container.y = videoHeight+_topPadding+_videoControlsGap;
				}
				_videoView.height = videoHeight;
				
				container.scrollRect = _maskContents?new Rectangle(0,0,width-_leftPadding-_rightPadding,height-_topPadding-_bottomPadding):null;
			}
		}
	}
}