package org.farmcode.display.controls
{
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.media.IMediaSource;
	import org.farmcode.media.video.IVideoSource;
	
	public class BufferBar extends Control
	{
		private static const PLAYED_BAR:String = "playedBar";
		private static const BUFFERED_BAR:String = "bufferedBar";
		
		
		public function get videoSource():IVideoSource{
			return _videoSource;
		}
		public function set videoSource(value:IVideoSource):void{
			if(_videoSource!=value){
				if(_videoSource){
					_videoSource.loadProgressChanged.removeHandler(onLoadChange);
					_videoSource.loadTotalChanged.removeHandler(onLoadChange);
					_videoSource.currentTimeChanged.removeHandler(onTimeChange);
					_videoSource.totalTimeChanged.removeHandler(onTimeChange);
				}
				_videoSource = value;
				if(_videoSource){
					_videoSource.loadProgressChanged.addHandler(onLoadChange);
					_videoSource.loadTotalChanged.addHandler(onLoadChange);
					_videoSource.currentTimeChanged.addHandler(onTimeChange);
					_videoSource.totalTimeChanged.addHandler(onTimeChange);
					_slider.maximum = _videoSource.totalTime;
					_slider.value = _videoSource.currentTime;
				}
			}
		}
		override public function get displayMeasurements() : Rectangle{
			return _slider.displayMeasurements;
		}
		
		private var _videoSource:IVideoSource;
		private var _slider:Slider;
		private var _playedBar:IDisplayAsset;
		private var _bufferedBar:IDisplayAsset;
		
		public function BufferBar(){
			super();
			_slider = new Slider();
			_slider.measurementsChanged.addHandler(onSliderMeasChange);
			_slider.valueChangeByUser.addHandler(onPlayheadChange);
		}
		override protected function bindToAsset() : void{
			_slider.asset = asset;
			_playedBar = _containerAsset.takeAssetByName(PLAYED_BAR,IDisplayAsset);
			_bufferedBar = _containerAsset.takeAssetByName(BUFFERED_BAR,IDisplayAsset);
		}
		override protected function unbindFromAsset() : void{
			_slider.asset = null;
			_containerAsset.returnAsset(_playedBar);
			_playedBar = null;
			_containerAsset.returnAsset(_bufferedBar);
			_bufferedBar = null;
		}
		override protected function draw() : void{
			
			
			var playedFract:Number = (_videoSource.totalTime>0?_videoSource.currentTime/_videoSource.totalTime:0);
			var loadFract:Number = _videoSource.loadProgress/_videoSource.loadTotal;
			
			if(_slider.direction==Direction.VERTICAL){
				
				if(_playedBar){
					var natWidth:Number = _playedBar.width/_playedBar.scaleX;
					if(natWidth<displayPosition.width){
						_playedBar.width = natWidth;
						_playedBar.x = (displayPosition.width-_playedBar.width)/2;
					}else{
						_playedBar.width = displayPosition.width;
						_playedBar.x = 0;
					}
					_playedBar.height = displayPosition.height*playedFract;
					_playedBar.y = 0;
				}
				
				if(_bufferedBar){
					natWidth = _bufferedBar.width/_bufferedBar.scaleX;
					if(natWidth<displayPosition.width){
						_bufferedBar.width = natWidth;
						_bufferedBar.x = (displayPosition.width-_bufferedBar.width)/2;
					}else{
						_bufferedBar.width = displayPosition.width;
						_bufferedBar.x = 0;
					}
					_bufferedBar.height = displayPosition.height*loadFract;
					_bufferedBar.y = 0;
				}
			}else{
				if(_playedBar){
					var natHeight:Number = _playedBar.height/_playedBar.scaleY;
					if(natHeight<displayPosition.height){
						_playedBar.height = natHeight;
						_playedBar.y = (displayPosition.height-_playedBar.height)/2;
					}else{
						_playedBar.height = displayPosition.height;
						_playedBar.y = 0;
					}
					_playedBar.width = displayPosition.width*playedFract;
					_playedBar.x = 0;
				}
				
				if(_bufferedBar){
					natHeight = _bufferedBar.height/_bufferedBar.scaleY;
					if(natHeight<displayPosition.height){
						_bufferedBar.height = natHeight;
						_bufferedBar.y = (displayPosition.height-_bufferedBar.height)/2;
					}else{
						_bufferedBar.height = displayPosition.height;
						_bufferedBar.y = 0;
					}
					_bufferedBar.width = displayPosition.width*loadFract;
					_bufferedBar.x = 0;
				}
			}
			_slider.setDisplayPosition(displayPosition.x,displayPosition.y,displayPosition.width,displayPosition.height);
		}
		protected function onSliderMeasChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		protected function onLoadChange(from:IMediaSource):void{
			invalidate();
		}
		protected function onTimeChange(from:IVideoSource):void{
			_slider.maximum = _videoSource.totalTime;
			_slider.value = _videoSource.currentTime
			invalidate();
		}
		protected function onPlayheadChange(from:Slider, value:Number):void{
			_videoSource.currentTime = value;
		}
	}
}