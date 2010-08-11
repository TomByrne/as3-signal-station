package org.farmcode.display.containers
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.ISpriteAsset;
	import org.farmcode.display.controls.BufferBar;
	import org.farmcode.display.controls.Button;
	import org.farmcode.display.controls.Control;
	import org.farmcode.display.controls.Slider;
	import org.farmcode.display.controls.SliderButton;
	import org.farmcode.display.controls.ToggleButton;
	import org.farmcode.display.layout.canvas.CanvasLayout;
	import org.farmcode.display.layout.canvas.CanvasLayoutInfo;
	import org.farmcode.display.utils.FullscreenUtil;
	import org.farmcode.media.IMediaSource;
	import org.farmcode.media.video.IVideoSource;
	
	use namespace DisplayNamespace
	
	public class VideoContainer extends MediaContainer
	{
		// asset children
		DisplayNamespace static const PLAY_PAUSE_BUTTON:String = "playPauseButton";
		DisplayNamespace static const STOP_BUTTON:String = "stopButton";
		DisplayNamespace static const FULLSCREEN_BUTTON:String = "fullscreenButton";
		DisplayNamespace static const REWIND_BUTTON:String = "rewindButton";
		DisplayNamespace static const VOLUME_SLIDER:String = "volumeSlider";
		DisplayNamespace static const BUFFER_BAR:String = "bufferBar";
		DisplayNamespace static const MUTE_BUTTON:String = "muteButton";
		DisplayNamespace static const CENTERED_PAUSE_BUTTON:String = "centredPauseButton";
		
		DisplayNamespace static const DEFAULT_HIDE_MOUSE_TIME:Number = 3;
		
		override public function set mediaSource(value:IMediaSource):void{
			if(super.mediaSource != value){
				if(_videoSource){
					_videoSource.playingChanged.removeHandler(onPlayingChange);
				}
				super.mediaSource = value;
				_videoSource = (value as IVideoSource);
				if(_videoSource){
					_videoSource.playingChanged.addHandler(onPlayingChange);
					syncToData();
				}
			}
		}
		/**
		 * If the mouse is inactive and sits over the playing video, it will be hidden
		 * after this amount of time (in seconds). Setting this to NaN will deactivate this feature.
		 */
		public function get hideMouseTime():Number{
			return _hideMouseTime;
		}
		public function set hideMouseTime(value:Number):void{
			if(_hideMouseTime!=value){
				_hideMouseTime = value;
				if(_mouseActive){
					activateMouse();
				}
			}
		}
		public function get fullScreenScale():Number{
			return _fullscreenUtil.fullScreenScale;
		}
		public function set fullScreenScale(value:Number):void{
			_fullscreenUtil.fullScreenScale = value;
		}
		DisplayNamespace function get fullscreenUtil():FullscreenUtil{
			checkFullScreenUtil();
			return _fullscreenUtil;
		}
		
		private var _hideMouseTime:Number = DEFAULT_HIDE_MOUSE_TIME;
		private var _hideMouseTimer:Timer;
		
		private var _playPauseButton:ToggleButton;
		private var _stopButton:Button;
		private var _fullscreenButton:ToggleButton;
		private var _rewindButton:Button;
		private var _centredPauseButton:ToggleButton;
		private var _muteButton:SliderButton;
		private var _volumeSlider:Slider;
		private var _bufferBar:BufferBar;
		
		private var _mouseActive:Boolean = true;
		private var _mouseOver:Boolean = true;
		
		private var _fullscreenUtil:FullscreenUtil;
		
		private var _uiLayout:CanvasLayout;
		
		private var _videoCover:ISpriteAsset;
		
		private var _videoSource:IVideoSource;
		
		public function VideoContainer(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			_uiLayout = new CanvasLayout(this);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_playPauseButton = bindButton(_playPauseButton, ToggleButton, PLAY_PAUSE_BUTTON,onPlayPauseClick) as ToggleButton;
			_stopButton = bindButton(_stopButton, Button, STOP_BUTTON,onStopClick);
			_fullscreenButton = bindButton(_fullscreenButton, ToggleButton,FULLSCREEN_BUTTON,onFullscreenClick) as ToggleButton;
			_rewindButton = bindButton(_rewindButton, Button,REWIND_BUTTON,onRewindClick);
			_muteButton = bindButton(_muteButton, SliderButton,MUTE_BUTTON,onMuteClick) as SliderButton;
			
			var pauseAsset:IInteractiveObjectAsset = _containerAsset.takeAssetByName(CENTERED_PAUSE_BUTTON,IInteractiveObjectAsset,true);
			if(pauseAsset){
				if(!_centredPauseButton){
					_centredPauseButton = new ToggleButton();
					_centredPauseButton.clicked.addHandler(onPlayPauseClick);
				}
				_centredPauseButton.setAssetAndPosition(pauseAsset);
			}
			_interactiveObjectAsset.mouseMoved.addHandler(onVideoMouse);
			_interactiveObjectAsset.rolledOut.addHandler(onVideoMouseOut);
			_interactiveObjectAsset.rolledOver.addHandler(onVideoMouse);
			
			var hadVolumeSlider:Boolean = (_volumeSlider!=null);
			_volumeSlider = bindControl(_volumeSlider,Slider,VOLUME_SLIDER,false) as Slider;
			if(_volumeSlider){
				if(!hadVolumeSlider){
					_volumeSlider.valueChange.addHandler(onVolumeSliderChange);
				}
			}
			
			var hadBufferBar:Boolean = (_bufferBar!=null);
			_bufferBar = bindControl(_bufferBar,BufferBar,BUFFER_BAR,true) as BufferBar;
			
			_videoCover = asset.createAsset(ISpriteAsset);
			_videoCover.doubleClicked.addHandler(onFullscreenClick);
			_videoCover.doubleClickEnabled = true;
			_videoCover.graphics.beginFill(0,0);
			_videoCover.graphics.drawRect(0,0,10,10);
			_videoCover.buttonMode = true;
			_videoCover.useHandCursor = false;
			_videoCover.keyUp.addHandler(onKeyUp);
			_containerAsset.addAssetAt(_videoCover,_containerAsset.getAssetIndex(_mediaBounds || _mediaContainer)+1);
			
			
			_mouseOver = true;
			syncToData();
			activateMouse();
		}
		protected function onKeyUp(e:KeyboardEvent, from:IDisplayAsset):void{
			if(e.charCode==Keyboard.SPACE){
				if(_videoSource){
					_videoSource.playing = !_videoSource.playing;
					assessPlaying();
				}
			}
		}
		protected function syncToData():void{
			if(_videoSource){
				if(_bufferBar){
					_bufferBar.videoSource = _videoSource;
				}
				if(_volumeSlider){
					_volumeSlider.value = _videoSource.volume;
				}
				if(_playPauseButton){
					_playPauseButton.selected = _videoSource.playing;
				}
				if(_muteButton){
					_muteButton.selected = _videoSource.muted;
				}
				assessPlaying();
			}
		}
		protected function bindButton(control:Control, controlClass:Class, name:String, clickHandler:Function):Button{
			var ret:Button = (bindControl(control, controlClass, name,false) as Button);
			if(!control && ret)ret.clicked.addHandler(clickHandler);
			return ret;
		}
		protected function bindControl(control:Control, controlClass:Class, name:String, bindBothSides:Boolean):Control{
			var asset:IInteractiveObjectAsset = _containerAsset.takeAssetByName(name,IInteractiveObjectAsset,true);
			if(asset){
				if(!control){
					control = new controlClass();
					_uiLayout.addSubject(control);
				}
				control.setAssetAndPosition(asset);
				var layout:CanvasLayoutInfo;
				if(_backing){
					var bounds:Rectangle = asset.getBounds(this.asset);
					var meas:Rectangle = control.displayMeasurements;
					if(meas){
						bounds.width = meas.width;
						bounds.height = meas.height;
					}
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
		// TODO: confirm that event handlers are being removed properly
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			
			_videoCover.doubleClicked.removeHandler(onFullscreenClick);
			_videoCover.keyUp.removeHandler(onKeyUp);
			_containerAsset.removeAsset(_videoCover);
			asset.destroyAsset(_videoCover);
			
			if(_playPauseButton){
				(_playPauseButton.asset as IInteractiveObjectAsset).mouseMoved.removeHandler(onVideoMouse);
				unbindControl(_playPauseButton);
			}
			unbindControl(_muteButton);
			unbindControl(_stopButton);
			unbindControl(_fullscreenButton);
			unbindControl(_centredPauseButton);
			unbindControl(_volumeSlider);
			unbindControl(_bufferBar);
		}
		protected function unbindControl(control:Control):void{
			if(control){
				_containerAsset.returnAsset(control.asset);
				control.asset = null;
			}
		}
		override protected function draw() : void{
			super.draw();
			_uiLayout.setDisplayPosition(0,0,displayPosition.width,displayPosition.height);
			if(_centredPauseButton){
				var meas:Rectangle = _centredPauseButton.displayMeasurements;
				var align:Rectangle =_mediaContainer.scrollRect;
				_centredPauseButton.setDisplayPosition(align.x+(align.width-meas.width)/2,align.y+(align.height-meas.height)/2,meas.width,meas.height);
			}
			_videoCover.x = _scrollRect.x;
			_videoCover.y = _scrollRect.y;
			_videoCover.width = _scrollRect.width;
			_videoCover.height = _scrollRect.height;
		}
		
		protected function onPlayPauseClick(from:Button):void{
			if(_videoSource){
				_videoSource.playing = !_videoSource.playing;
				assessPlaying();
			}
		}
		protected function onStopClick(from:Button):void{
			if(_videoSource){
				_videoSource.playing = false;
			}
		}
		protected function onFullscreenClick(... params):void{
			if(_videoSource){
				checkFullScreenUtil();
				_fullscreenUtil.active = !_fullscreenUtil.active;
				_fullscreenButton.selected = _fullscreenUtil.active;
			}
		}
		protected function checkFullScreenUtil():void{
			if(!_fullscreenUtil){
				_fullscreenUtil = new FullscreenUtil(this);
				_fullscreenUtil.activeChange.addHandler(onFullscreenChange);
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
		protected function onPlayingChange(from:IVideoSource):void{
			assessPlaying();
		}
		protected function assessPlaying():void{
			if(_videoSource){
				if(_playPauseButton)_playPauseButton.selected = _videoSource.playing;
				if(_centredPauseButton){
					_centredPauseButton.selected = _videoSource.playing;
					_centredPauseButton.asset.alpha = (!_videoSource.playing || (_mouseOver && _mouseActive))?1:0;
					if(_mouseOver){
						if(_videoSource.playing && !_mouseActive){
							Mouse.hide();
						}else{
							Mouse.show();
						}
					}
				}
			}
		}
		protected function assessMuted():void{
			if(_videoSource){
				if(_muteButton)_muteButton.selected = _videoSource.muted;
			}
		}
		protected function onVolumeSliderChange(from:Slider, value:Number):void{
			if(_videoSource){
				_videoSource.volume = value;
			}
		}
		protected function onMuteClick(from:ToggleButton):void{
			if(_videoSource){
				_videoSource.muted = !_videoSource.muted;
				_muteButton.selected = _videoSource.muted;
			}
		}
		protected function onVideoMouseOut(from:IInteractiveObjectAsset, mouseInfo:IMouseActInfo):void{
			_mouseOver = false;
			Mouse.show();
			activateMouse();
			assessPlaying();
		}
		protected function onVideoMouse(from:IInteractiveObjectAsset, mouseInfo:IMouseActInfo):void{
			_mouseOver = true;
			activateMouse();
			assessPlaying();
		}
		protected function activateMouse():void{
			_mouseActive = true;
			if(!isNaN(_hideMouseTime)){
				if(_hideMouseTimer){
					_hideMouseTimer.stop();
					_hideMouseTimer.reset();
					_hideMouseTimer.delay = _hideMouseTime*1000;
				}else{
					_hideMouseTimer = new Timer(_hideMouseTime*1000,1);
					_hideMouseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHideTimerComplete);
				}
				_hideMouseTimer.start();
			}else if(_hideMouseTimer){
				_hideMouseTimer.stop();
				_hideMouseTimer.reset();
			}
		}
		protected function onHideTimerComplete(e:Event):void{
			_mouseActive = false;
			assessPlaying();
		}
	}
}