package org.tbyrne.display.containers
{
	import fl.transitions.easing.Regular;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import org.goasap.events.GoEvent;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IBooleanData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.ISprite;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.controls.BufferBar;
	import org.tbyrne.display.controls.Button;
	import org.tbyrne.display.controls.Control;
	import org.tbyrne.display.controls.Slider;
	import org.tbyrne.display.controls.SliderButton;
	import org.tbyrne.display.controls.TextLabel;
	import org.tbyrne.display.controls.ToggleButton;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.display.layout.canvas.CanvasLayout;
	import org.tbyrne.display.layout.canvas.CanvasLayoutInfo;
	import org.tbyrne.formatters.patternFormatters.VideoProgressFormatter;
	import org.tbyrne.media.IMediaSource;
	import org.tbyrne.media.video.IVideoSource;
	import org.tbyrne.media.video.VolumeMemory;
	import org.tbyrne.tweening.LooseTween;
	
	use namespace DisplayNamespace
	
	public class VideoContainer extends MediaContainer
	{
		// asset children
		DisplayNamespace static const CONTROL_CONTAINER:String = "controlContainer";
		DisplayNamespace static const PLAY_PAUSE_BUTTON:String = "playPauseButton";
		DisplayNamespace static const STOP_BUTTON:String = "stopButton";
		DisplayNamespace static const FULLSCREEN_BUTTON:String = "fullscreenButton";
		DisplayNamespace static const REWIND_BUTTON:String = "rewindButton";
		DisplayNamespace static const VOLUME_SLIDER:String = "volumeSlider";
		DisplayNamespace static const BUFFER_BAR:String = "bufferBar";
		DisplayNamespace static const MUTE_BUTTON:String = "muteButton";
		DisplayNamespace static const CENTERED_PAUSE_BUTTON:String = "centredPauseButton";
		DisplayNamespace static const PROGRESS_LABEL:String = "progressLabel";
		
		DisplayNamespace static const STATE_FULL_SCREEN:String = "fullScreen";
		DisplayNamespace static const STATE_NOT_FULL_SCREEN:String = "notFullScreen";
		
		
		DisplayNamespace static const DEFAULT_DISABLE_TIME:Number = 1;
		// the amount of time in seconds it takes the control container to move in or out.
		private static const TRANS_DURATION:Number = 0.25;
		
		override public function set mediaSource(value:IMediaSource):void{
			attemptInit()
			if(super.mediaSource != value){
				if(_videoSource){
					_videoSource.playingChanged.removeHandler(onPlayingChanged);
					_videoSource.volumeChanged.removeHandler(onDataChanged);
					_videoSource.muted.booleanValueChanged.removeHandler(onMuteChanged);
					if(_videoProgressProvider)_videoProgressProvider.videoSource = null;
				}
				super.mediaSource = value;
				_videoSource = (value as IVideoSource);
				_volumeMemory.videoSource = _videoSource;
				if(_videoSource){
					if(_muteButton)_muteButton.data = _videoSource.muted;
					_videoSource.playingChanged.addHandler(onPlayingChanged);
					_videoSource.volumeChanged.addHandler(onDataChanged);
					_videoSource.muted.booleanValueChanged.addHandler(onMuteChanged);
					if(_videoProgressProvider)_videoProgressProvider.videoSource = _videoSource;
					syncToData();
					if(!isBound){
						_openFract = 1;
					}else if(_hasControlCont){
						transTo(1);
					}
					_isPlaying.booleanValue = _videoSource.playing;
				}else{
					if(_muteButton)_muteButton.data = null;
					if(!isBound){
						_openFract = 0;
					}else if(_hasControlCont){
						transTo(0);
					}
					_isPlaying.booleanValue = false;
				}
			}
		}
		/**
		 * If the mouse is inactive and sits over the playing video, it will be hidden
		 * after this amount of time (in seconds). Setting this to NaN will deactivate this feature.
		 */
		public function get disableTime():Number{
			return _disableTime;
		}
		public function set disableTime(value:Number):void{
			if(_disableTime!=value){
				_disableTime = value;
				if(_mouseActive){
					activateMouse();
				}
			}
		}
		
		/**
		 * The pattern to be used to generate the text for the Progress Label.
		 * Acceptable tokens are:
		 * <ul>
		 * 	<li>${tt}	- The total time of the video (in the format 0:00)</li>
		 * 	<li>${rt}	- The time remaining (in the format 0:00)</li>
		 * 	<li>${pt}	- The time of the playhead (in the format 0:00)</li>
		 * 	<li>${ts}	- The total size of the video (in the format 500kb, 1.2mb)</li>
		 * 	<li>${ls}	- The amount of video currently loaded (in the format 500kb, 1.2mb)</li>
		 * 	<li>${ps}	- The percent loaded</li>
		 * 	<li>${su}	- The units that the size values are in (e.g. kb, mb, etc.)</li>
		 * </ul>
		 */
		public function get progressLabelPattern():String{
			return _progressLabelPattern;
		}
		public function set progressLabelPattern(value:String):void{
			if(_progressLabelPattern!=value){
				_progressLabelPattern = value;
				if(_videoProgressProvider)checkProgressPattern();
			}
		}
		
		/**
		 * This exposes whether this videos full screen button is selected,
		 * which can be used in conjunction with a class like FullscreenUtil
		 * to achieve full screen functionality.
		 */
		public function get fullScreenSelected():IBooleanProvider{
			attemptInit();
			return _fullScreenSelected;
		}
		
		private var _disableTime:Number = DEFAULT_DISABLE_TIME;
		private var _disableTimer:Timer;
		
		private var _tweenRunning:Boolean;
		private var _openTween:LooseTween;
		private var _openFract:Number = 0;
		private var _controlScrollRect:Rectangle;
		private var _hasControlCont:Boolean;
		
		protected var _playPauseButton:ToggleButton;
		protected var _stopButton:Button;
		protected var _fullScreenButton:ToggleButton;
		protected var _rewindButton:Button;
		protected var _centredPauseButton:ToggleButton;
		protected var _muteButton:SliderButton;
		protected var _volumeSlider:Slider;
		protected var _bufferBar:BufferBar;
		protected var _progressLabel:TextLabel;
		
		private var _controlContainer:ContainerView;
		
		private var _videoProgressProvider:VideoProgressFormatter;
		private var _videoProgressProviderPattern:StringData;
		private var _assumedPattern:String;
		
		private var _mouseActive:Boolean = true;
		private var _mouseOver:Boolean;
		private var _mouseOverControls:Boolean;
		
		private var _isPlaying:BooleanData;
		
		private var _progressLabelPattern:String;
		private var _mainLayout:CanvasLayout;
		private var _contLayout:CanvasLayout;
		private var _videoCover:ISprite;
		private var _videoSource:IVideoSource;
		
		private var _volumeMemory:VolumeMemory;
		private var _fullScreenSelected:BooleanData;
		
		protected var _fullScreenState:StateDef = new StateDef([STATE_NOT_FULL_SCREEN,STATE_FULL_SCREEN],0);
		protected var _childStateList:Array = [_fullScreenState];
		
		public function VideoContainer(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_fullScreenState);
			return fill;
		}
		override protected function init() : void{
			super.init();
			_volumeMemory = new VolumeMemory();
			_mainLayout = new CanvasLayout(this);
			_contLayout = new CanvasLayout();
			
			_isPlaying = new BooleanData();
			_isPlaying.booleanValueChanged.addHandler(onPlayingDataChanged);
			
			_fullScreenSelected = new BooleanData();
			_fullScreenSelected.booleanValueChanged.addHandler(onFullscreenChange);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			
			_controlContainer = bindView(_controlContainer,ContainerView,CONTROL_CONTAINER,true);
			_contLayout.scopeView = _controlContainer;
			_hasControlCont = (_controlContainer && _controlContainer.asset);
			if(_hasControlCont){
				var interCont:IInteractiveObject = _controlContainer.asset as IInteractiveObject;
				interCont.mousedOver.addHandler(onMousedOverCont);
				interCont.mousedOut.addHandler(onMousedOutCont);
			}
			
			_playPauseButton = bindView(_playPauseButton, ToggleButton, PLAY_PAUSE_BUTTON,false);
			if(_playPauseButton)_playPauseButton.data = _isPlaying;
			_stopButton = bindButton(_stopButton, Button, STOP_BUTTON,onStopClick);
			_rewindButton = bindButton(_rewindButton, Button,REWIND_BUTTON,onRewindClick);
			
			_fullScreenButton = bindView(_fullScreenButton, ToggleButton,FULLSCREEN_BUTTON,false);
			if(_fullScreenButton)_fullScreenButton.data = _fullScreenSelected;
			
			_muteButton = bindView(_muteButton, SliderButton,MUTE_BUTTON, false);
			if(_muteButton && _videoSource)_muteButton.data = _videoSource.muted;
			
			var pauseAsset:IInteractiveObject = _containerAsset.takeAssetByName(CENTERED_PAUSE_BUTTON,true);
			if(pauseAsset){
				if(!_centredPauseButton){
					_centredPauseButton = new ToggleButton();
					//_centredPauseButton.clicked.addHandler(onPlayPauseClick);
					_centredPauseButton.data = _isPlaying;
				}
				_centredPauseButton.setAssetAndPosition(pauseAsset);
			}
			_interactiveObjectAsset.mouseMoved.addHandler(onVideoMouse);
			_interactiveObjectAsset.rolledOut.addHandler(onVideoMouseOut);
			_interactiveObjectAsset.rolledOver.addHandler(onVideoMouse);
			
			var hadVolumeSlider:Boolean = (_volumeSlider!=null);
			_volumeSlider = bindView(_volumeSlider,Slider,VOLUME_SLIDER,false) as Slider;
			if(_volumeSlider && !hadVolumeSlider){
				_volumeSlider.valueChangedByUser.addHandler(onVolumeSliderChange);
			}
			
			_bufferBar = bindView(_bufferBar,BufferBar,BUFFER_BAR,true) as BufferBar;
			
			_progressLabel = bindView(_progressLabel,TextLabel,PROGRESS_LABEL,false) as TextLabel;
			if(_progressLabel){
				_assumedPattern = _progressLabel.data;
				if(!_videoProgressProvider)_videoProgressProvider = new VideoProgressFormatter(_videoSource,_videoProgressProviderPattern = new StringData());
				_progressLabel.data = _videoProgressProvider;
				checkProgressPattern();
			}
			
			_videoCover = asset.factory.createHitArea();
			_videoCover.doubleClicked.addHandler(onFullscreenToggle);
			_videoCover.doubleClickEnabled = true;
			_videoCover.buttonMode = true;
			_videoCover.useHandCursor = false;
			_videoCover.keyUp.addHandler(onKeyUp);
			_containerAsset.addAssetAt(_videoCover,_containerAsset.getAssetIndex(_mediaBounds || _mediaContainer)+1);
			
			
			syncToData();
			activateMouse();
		}
		protected function checkProgressPattern():void{
			if(_progressLabelPattern){
				_videoProgressProviderPattern.stringValue = _progressLabelPattern;
			}else if(_assumedPattern){
				_videoProgressProviderPattern.stringValue = _assumedPattern;
			}else{
				_videoProgressProviderPattern.stringValue = null;
			}
		}
		protected function onKeyUp(from:IDisplayObject, info:IKeyActInfo):void{
			if(info.charCode==Keyboard.SPACE){
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
				if(_muteButton){
					_muteButton.value = _videoSource.volume;
				}
				assessPlaying();
			}
		}
		protected function bindButton(control:Control, controlClass:Class, name:String, clickHandler:Function):*{
			var ret:Button = bindView(control, controlClass, name,false);
			if(!control && ret)ret.clicked.addHandler(clickHandler);
			return ret;
		}
		protected function bindView(layoutView:LayoutView, controlClass:Class, name:String, bindBothSides:Boolean):*{
			var asset:IDisplayObject = _containerAsset.takeAssetByName(name,true);
			var layout:CanvasLayout = _mainLayout;
			var parent:IDisplayObjectContainer = _containerAsset;
			var parentMeas:Point;
			if(!asset){
				if(_controlContainer && _controlContainer.asset){
					parent = (_controlContainer.asset as IDisplayObjectContainer);
					asset = parent.takeAssetByName(name,true);
					layout = _contLayout;
					parentMeas = _controlContainer.measurements;
				}
			}else{
				parentMeas = new Point(_backing.width,_backing.height);
			}
			if(asset){
				asset.addStateList(_childStateList,false);
				if(!layoutView){
					layoutView = new controlClass();
					layout.addSubject(layoutView);
				}
				var origX:Number = asset.x;
				var origY:Number = asset.y;
				layoutView.setAssetAndPosition(asset);
				var layoutInfo:CanvasLayoutInfo;
				
				var bounds:Rectangle = asset.getBounds(parent);
				var meas:Point = layoutView.measurements;
				if(meas){
					bounds.x = origX;
					bounds.y = origY;
					bounds.width = meas.x;
					bounds.height = meas.y;
				}
				layoutInfo = layoutView.layoutInfo as CanvasLayoutInfo;
				if(!layoutInfo){
					layoutInfo = new CanvasLayoutInfo();
				}
				layoutInfo.bottom = parentMeas.y-bounds.bottom;
				var atLeft:Boolean = (bounds.x+bounds.width/2<parentMeas.x/2);
				if(atLeft || bindBothSides){
					layoutInfo.left = bounds.x;
				}
				if(!atLeft || bindBothSides){
					layoutInfo.right = parentMeas.x-bounds.right;
				}
				layoutView.layoutInfo = layoutInfo;
			}
			return layoutView;
		}
		// TODO: confirm that event handlers are being removed properly
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			
			_videoCover.doubleClicked.removeHandler(onFullscreenToggle);
			_videoCover.keyUp.removeHandler(onKeyUp);
			_containerAsset.removeAsset(_videoCover);
			asset.factory.destroyAsset(_videoCover);
			
			if(_playPauseButton){
				(_playPauseButton.asset as IInteractiveObject).mouseMoved.removeHandler(onVideoMouse);
				unbindView(_playPauseButton);
			}
			if(_muteButton){
				_muteButton.data = null;
				unbindView(_muteButton);
			}
			unbindView(_stopButton);
			unbindView(_fullScreenButton);
			unbindView(_centredPauseButton);
			unbindView(_volumeSlider);
			unbindView(_bufferBar);
			
			if(_progressLabel){
				_progressLabel.data = _assumedPattern;
			}
			unbindView(_progressLabel);
			
			if(_hasControlCont){
				var interCont:IInteractiveObject = _controlContainer.asset as IInteractiveObject;
				interCont.mousedOver.addHandler(onMousedOverCont);
				interCont.mousedOut.addHandler(onMousedOutCont);
				unbindView(_controlContainer);
			}
		}
		protected function onMousedOverCont(from:IInteractiveObject, mouseActInfo:IMouseActInfo):void{
			_mouseOverControls = true;
		}
		protected function onMousedOutCont(from:IInteractiveObject, mouseActInfo:IMouseActInfo):void{
			_mouseOverControls = false;
			if(!_mouseActive)transTo(0);
		}
		protected function unbindView(layoutView:LayoutView):void{
			if(layoutView){
				layoutView.asset.parent.returnAsset(layoutView.asset);
				layoutView.asset.removeStateList(_childStateList);
				layoutView.asset = null;
			}
		}
		override protected function commitSize():void{
			super.commitSize();
			_mainLayout.setSize(size.x,size.y);
			
			if(_centredPauseButton){
				var align:Rectangle =_mediaContainer.scrollRect;
				var meas:Point = _centredPauseButton.measurements;
				_centredPauseButton.setPosition(align.x+(align.width-meas.x)/2,align.y+(align.height-meas.y)/2);
				_centredPauseButton.setSize(meas.x,meas.y);
			}
			_videoCover.setSizeAndPos(_scrollRect.x,_scrollRect.y,_scrollRect.width,_scrollRect.height);
			
			if(_hasControlCont){
				_mainLayout.validate();
				var pos:Point = _controlContainer.position;
				_contLayout.setSize(pos.x,pos.y);
				drawControlScrollRect();
			}
		}
		protected function drawControlScrollRect() : void{
			if(_openFract==1){
				_controlContainer.asset.scrollRect = null;
			}else{
				if(!_controlScrollRect)_controlScrollRect = new Rectangle();
				var layout:CanvasLayoutInfo = (_controlContainer.layoutInfo as CanvasLayoutInfo);
				
				var hasTop:Boolean = (!isNaN(layout.top));
				var hasLeft:Boolean = (!isNaN(layout.left));
				var hasBottom:Boolean = (!isNaN(layout.bottom));
				var hasRight:Boolean = (!isNaN(layout.right));
				
				var pos:Point = _controlContainer.position;
				
				_controlScrollRect.width = pos.x;
				_controlScrollRect.height = pos.y;
				if(hasBottom && !hasTop){
					// aligned to bottom
					_controlScrollRect.x = 0;
					_controlScrollRect.y = -pos.y*(1-_openFract);
				}else if(!hasBottom && hasTop){
					// aligned to top
					_controlScrollRect.x = 0;
					_controlScrollRect.y = pos.y*(1-_openFract);
				}else if(!hasRight && hasLeft){
					// aligned to left
					_controlScrollRect.x = pos.x*(1-_openFract);
					_controlScrollRect.y = 0;
				}else if(hasRight && !hasLeft){
					// aligned to right
					_controlScrollRect.x = -pos.x*(1-_openFract);
					_controlScrollRect.y = 0;
				}
				_controlContainer.asset.scrollRect = _controlScrollRect;
			}
		}
		
		/*protected function onPlayPauseClick(from:Button):void{
			if(_videoSource){
				_videoSource.playing = !_videoSource.playing;
				assessPlaying();
			}
		}*/
		protected function onStopClick(from:Button):void{
			if(_videoSource){
				_videoSource.playing = false;
			}
		}
		protected function onFullscreenToggle(from:IInteractiveObject, mouseActInfo:IMouseActInfo):void{
			//checkFullScreenUtil();
			//_fullscreenUtil.active = !_fullscreenUtil.active;
			_fullScreenSelected.booleanValue = !_fullScreenSelected.booleanValue;
			//if(_fullScreenButton)_fullScreenButton.selected = _fullScreenSelected.booleanValue;
		}
		/*protected function onFullscreenClick(from:ToggleButton):void{
			//checkFullScreenUtil();
			_fullScreenSelected.booleanValue = from.selected;
		}*/
		/*protected function checkFullScreenUtil():void{
			if(!_fullscreenUtil){
				_fullscreenUtil = new FullscreenUtil(this);
				_fullscreenUtil.activeChange.addHandler(onFullscreenChange);
			}
		}*/
		protected function onFullscreenChange(from:BooleanData):void{
			//if(_fullScreenButton)_fullScreenButton.selected = _fullScreenSelected.booleanValue;
			_fullScreenState.selection = (_fullScreenSelected.booleanValue?1:0);
		}
		protected function onRewindClick(from:Button):void{
			if(_videoSource){
				_videoSource.currentTime.numericalValue = 0;
			}
		}
		protected function onPlayingChanged(from:IVideoSource):void{
			_isPlaying.booleanValue = _videoSource.playing;
			assessPlaying();
		}
		protected function onPlayingDataChanged(from:IBooleanProvider):void{
			if(_videoSource)_videoSource.playing = _isPlaying.booleanValue;
			//assessPlaying();
		}
		protected function onDataChanged(... params):void{
			syncToData();
		}
		protected function assessPlaying():void{
			var isPlaying:Boolean = (_videoSource && _videoSource.playing);
			//if(_playPauseButton)_playPauseButton.selected = isPlaying;
			
			var active:Boolean = _videoSource && (!isPlaying || _mouseActive);
			
			setControlsActive([_playPauseButton,_rewindButton,_muteButton,_stopButton,_fullScreenButton,_volumeSlider,_bufferBar,_progressLabel],active);
			
			if(_centredPauseButton){
				//_centredPauseButton.selected = isPlaying;
				_centredPauseButton.active = (!isPlaying || (_mouseOver && _mouseActive));
				
				if(_mouseOver){
					if(isPlaying && !_mouseActive){
						Mouse.hide();
					}else{
						Mouse.show();
					}
				}
			}
		}
		protected function setControlsActive(controls:Array, active:Boolean):void{
			for each(var control:Control in controls){
				if(control){
					control.active = active;
				}
			}
		}
		protected function onVolumeSliderChange(from:Control, value:Number):void{
			if(_videoSource){
				if(value || _videoSource.muted.booleanValue){
					_videoSource.volume = value;
				}else{
					_videoSource.muted.booleanValue = true;
				}
			}
		}
		protected function onMuteChanged(from:IBooleanData):void{
			if(_videoSource){
				if(!_videoSource.muted.booleanValue && _videoSource.volume<=0){
					_videoSource.volume = 1;
				}
				syncToData();
			}
		}
		protected function onVideoMouseOut(from:IInteractiveObject, mouseInfo:IMouseActInfo):void{
			_mouseOver = false;
			Mouse.show();
			activateMouse();
			assessPlaying();
		}
		protected function onVideoMouse(from:IInteractiveObject, mouseInfo:IMouseActInfo):void{
			_mouseOver = true;
			activateMouse();
			assessPlaying();
		}
		protected function activateMouse():void{
			_mouseActive = true;
			if(_hasControlCont && _videoSource)transTo(1);
			if(!isNaN(_disableTime)){
				if(_disableTimer){
					_disableTimer.stop();
					_disableTimer.reset();
					_disableTimer.delay = _disableTime*1000;
				}else{
					_disableTimer = new Timer(_disableTime*1000,1);
					_disableTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHideTimerComplete);
				}
				_disableTimer.start();
			}else if(_disableTimer){
				_disableTimer.stop();
				_disableTimer.reset();
			}
		}
		protected function onHideTimerComplete(e:Event):void{
			_mouseActive = false;
			assessPlaying();
			if(_hasControlCont && !_mouseOverControls)transTo(0);
		}
		
		protected function transTo(value:Number, delay:Number=0) : void{
			if((!_tweenRunning && value!=_openFract) || (_tweenRunning && _openTween.destProps.value!=value)){
				_tweenRunning = true;
				if(_openTween){
					_openTween.stop();
				}else{
					_openTween = new LooseTween({value:_openFract},null,null,TRANS_DURATION);
					_openTween.addEventListener(GoEvent.UPDATE,onUpdate);
					_openTween.addEventListener(GoEvent.COMPLETE,onComplete);
				}
				var easing:Function = (value==0?Regular.easeIn:(_openFract==0?Regular.easeOut:Regular.easeInOut));
				_openTween.delay = delay;
				_openTween.easing = easing;
				_openTween.destProps = {value:value};
				_openTween.start();
			}
		}
		protected function onUpdate(e:GoEvent) : void{
			_openFract = _openTween.target.value;
			drawControlScrollRect();
		}
		protected function onComplete(e:GoEvent) : void{
			_tweenRunning = false;
		}
	}
}