package org.farmcode.display.behaviour.containers
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.behaviour.controls.BufferBar;
	import org.farmcode.display.behaviour.controls.Button;
	import org.farmcode.display.behaviour.controls.Control;
	import org.farmcode.display.behaviour.controls.Slider;
	import org.farmcode.display.behaviour.controls.ToggleButton;
	import org.farmcode.display.behaviour.misc.FullscreenUtil;
	import org.farmcode.display.layout.canvas.CanvasLayout;
	import org.farmcode.display.layout.canvas.CanvasLayoutInfo;
	import org.farmcode.media.IMediaSource;
	import org.farmcode.media.video.IVideoSource;
	
	public class VideoContainer extends MediaContainer
	{
		// asset children
		private static const PLAY_PAUSE_BUTTON:String = "playPauseButton";
		private static const STOP_BUTTON:String = "stopButton";
		private static const FULLSCREEN_BUTTON:String = "fullscreenButton";
		private static const REWIND_BUTTON:String = "rewindButton";
		private static const VOLUME_SLIDER:String = "volumeSlider";
		private static const BUFFER_BAR:String = "bufferBar";
		private static const MUTE_BUTTON:String = "muteButton";
		private static const CENTERED_PAUSE_BUTTON:String = "centredPauseButton";
		
		
		override public function set mediaSource(value:IMediaSource):void{
			if(super.mediaSource != value){
				if(_videoSource){
					_videoSource.mutedChanged.removeHandler(onMutedChanged);
					_videoSource.volumeChanged.removeHandler(onVolumeChanged);
					_videoSource.playingChanged.removeHandler(onPlayingChanged);
				}
				super.mediaSource = value;
				_videoSource = (value as IVideoSource);
				if(_videoSource){
					_videoSource.mutedChanged.addHandler(onMutedChanged);
					_videoSource.volumeChanged.addHandler(onVolumeChanged);
					_videoSource.playingChanged.addHandler(onPlayingChanged);
					syncToData();
				}
			}
		}
		
		private var _playPauseButton:ToggleButton;
		private var _stopButton:Button;
		private var _fullscreenButton:ToggleButton;
		private var _rewindButton:Button;
		private var _centredPauseButton:ToggleButton;
		private var _muteButton:ToggleButton;
		private var _centredPauseButtonPos:Control;
		private var _volumeSlider:Slider;
		private var _bufferBar:BufferBar;
		
		private var _videoMouseOver:Boolean;
		
		private var _fullscreenUtil:FullscreenUtil;
		
		protected var _uiLayout:CanvasLayout = new CanvasLayout();
		
		private var _videoSource:IVideoSource;
		
		public function VideoContainer(asset:DisplayObject=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_playPauseButton = bindButton(_playPauseButton, ToggleButton, PLAY_PAUSE_BUTTON,onPlayPauseClick) as ToggleButton;
			_stopButton = bindButton(_stopButton, Button, STOP_BUTTON,onStopClick);
			_fullscreenButton = bindButton(_fullscreenButton, ToggleButton,FULLSCREEN_BUTTON,onFullscreenClick) as ToggleButton;
			_rewindButton = bindButton(_rewindButton, Button,REWIND_BUTTON,onRewindClick);
			_muteButton = bindButton(_muteButton, ToggleButton,MUTE_BUTTON,onMuteClick) as ToggleButton;
			
			var asset:DisplayObject = containerAsset.getChildByName(CENTERED_PAUSE_BUTTON);
			if(asset){
				if(!_centredPauseButton){
					_centredPauseButton = new ToggleButton();
					_centredPauseButton.rollOutAct.addHandler(onVideoMouse);
					_centredPauseButton.rollOverAct.addHandler(onVideoMouse);
					_centredPauseButton.clickAct.addHandler(onPlayPauseClick);
					_centredPauseButtonPos = new Control();
				}
				_centredPauseButton.setAssetAndPosition(asset);
				_centredPauseButtonPos.asset = asset;
			}
			
			
			var hadVolumeSlider:Boolean = (_volumeSlider!=null);
			_volumeSlider = bindControl(_volumeSlider,Slider,VOLUME_SLIDER,false) as Slider;
			if(_volumeSlider){
				if(!hadVolumeSlider){
					_volumeSlider.valueChange.addHandler(onVolumeSliderChange);
				}
			}
			
			var hadBufferBar:Boolean = (_bufferBar!=null);
			_bufferBar = bindControl(_bufferBar,BufferBar,BUFFER_BAR,true) as BufferBar;
			
			syncToData();
		}
		protected function syncToData():void{
			if(_videoSource){
				if(_bufferBar){
					_bufferBar.videoSource = _videoSource;
				}
				if(_playPauseButton){
					_playPauseButton.selected = _videoSource.playing;
				}
				assessVolume();
				assessPlaying();
			}
		}
		protected function bindButton(control:Control, controlClass:Class, name:String, clickHandler:Function):Button{
			var ret:Button = (bindControl(control, controlClass, name,false) as Button);
			if(!control && ret)ret.clickAct.addHandler(clickHandler);
			return ret;
		}
		protected function bindControl(control:Control, controlClass:Class, name:String, bindBothSides:Boolean):Control{
			var asset:DisplayObject = containerAsset.getChildByName(name);
			if(asset){
				if(!control){
					control = new controlClass();
					_uiLayout.addSubject(control);
				}
				control.setAssetAndPosition(asset);
				var layout:CanvasLayoutInfo;
				if(_backing){
					var bounds:Rectangle = asset.getBounds(_backing);
					layout = _uiLayout.layoutInfo as CanvasLayoutInfo;
					if(!layout){
						layout = new CanvasLayoutInfo();
					}
					layout.bottom = _backing.height-bounds.bottom;
					var atLeft:Boolean = (bounds.x+bounds.width/2<_backing.width/2);
					if(atLeft || bindBothSides){
						layout.left = bounds.x;
					}
					if(!atLeft || bindBothSides){
						layout.right = _backing.width-bounds.right;
					}
				}
				control.layoutInfo = layout;
			}
			return control;
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			unbindControl(_playPauseButton);
			unbindControl(_stopButton);
			unbindControl(_fullscreenButton);
			unbindControl(_centredPauseButton);
			unbindControl(_volumeSlider);
			unbindControl(_bufferBar);
			unbindControl(_centredPauseButtonPos);
		}
		protected function unbindControl(control:Control):void{
			if(control){
				control.asset = null;
			}
		}
		override protected function draw() : void{
			super.draw();
			_uiLayout.setDisplayPosition(0,0,displayPosition.width,displayPosition.height);
			if(_centredPauseButton){
				_centredPauseButton.setDisplayPosition(_mediaContainer.scrollRect.x,_mediaContainer.scrollRect.y,_mediaContainer.scrollRect.width,_mediaContainer.scrollRect.height);
				_centredPauseButtonPos.setDisplayPosition(_mediaContainer.scrollRect.x,_mediaContainer.scrollRect.y,_mediaContainer.scrollRect.width,_mediaContainer.scrollRect.height);
			}
		}
		
		protected function onPlayPauseClick(from:Button):void{
			if(_videoSource){
				_videoSource.playing = !_videoSource.playing;
				if(_playPauseButton)_playPauseButton.selected = _videoSource.playing;
			}
		}
		protected function onStopClick(from:Button):void{
			if(_videoSource){
				_videoSource.playing = false;
			}
		}
		protected function onFullscreenClick(from:Button):void{
			if(_videoSource){
				if(!_fullscreenUtil){
					_fullscreenUtil = new FullscreenUtil(this);
					_fullscreenUtil.activeChange.addHandler(onFullscreenChange);
				}
				_fullscreenUtil.active = !_fullscreenUtil.active;
				_fullscreenButton.selected = _fullscreenUtil.active;
			}
		}
		protected function onFullscreenChange(from:FullscreenUtil, active:Boolean):void{
			_fullscreenButton.selected = active;
		}
		protected function onRewindClick(from:Button):void{
			if(_videoSource){
				_videoSource.currentTime = 0;
			}
		}
		protected function onPlayingChanged(from:IVideoSource):void{
			assessPlaying();
		}
		protected function onVolumeChanged(from:IVideoSource):void{
			assessVolume();
		}
		protected function onMutedChanged(from:IVideoSource):void{
			assessVolume();
		}
		protected function assessPlaying():void{
			if(_videoSource){
				if(_playPauseButton)_playPauseButton.selected = _videoSource.playing;
				if(_centredPauseButton){
					_centredPauseButton.selected = _videoSource.playing;
					_centredPauseButton.asset.alpha = (!_videoSource.playing || _centredPauseButton.over)?1:0;
				}
			}
		}
		protected function assessVolume():void{
			if(_videoSource){
				if(_videoSource.muted){
					if(_muteButton)_muteButton.selected = true;
					if(_volumeSlider){
						_volumeSlider.value = 0;
					}
				}else{
					if(_muteButton)_muteButton.selected = false;
					if(_volumeSlider){
						_volumeSlider.value = _videoSource.volume;
					}
				}
			}
		}
		protected function onVolumeSliderChange(from:Slider, value:Number):void{
			if(_videoSource){
				if(value){
					_videoSource.muted = false;
					_videoSource.volume = value;
				}else{
					_videoSource.muted = true;
				}
			}
		}
		protected function onMuteClick(from:ToggleButton):void{
			if(_videoSource){
				_videoSource.muted = !_videoSource.muted;
				_muteButton.selected = _videoSource.muted;
			}
		}
		protected function onVideoMouse(from:Button):void{
			assessPlaying();
		}
	}
}