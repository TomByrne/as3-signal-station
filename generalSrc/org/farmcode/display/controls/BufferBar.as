package org.farmcode.display.controls
{
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.IShapeAsset;
	import org.farmcode.display.assets.ISpriteAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.media.IMediaSource;
	import org.farmcode.media.video.IVideoSource;
	
	public class BufferBar extends Control
	{
		private static const PLAYED_BAR:String = "playedBar";
		private static const BUFFERED_BAR:String = "bufferedBar";
		
		
		override public function set active(value:Boolean):void{
			_slider.active = value;
			super.active = value;
		}
		public function get videoSource():IVideoSource{
			return _videoSource;
		}
		public function set videoSource(value:IVideoSource):void{
			if(_videoSource!=value){
				if(_videoSource){
					_videoSource.loadProgress.numericalValueChanged.removeHandler(onLoadChange);
					_videoSource.loadTotal.numericalValueChanged.removeHandler(onLoadChange);
					_videoSource.currentTime.numericalValueChanged.removeHandler(onTimeChange);
					_videoSource.totalTime.numericalValueChanged.removeHandler(onTimeChange);
				}
				_videoSource = value;
				if(_videoSource){
					_videoSource.loadProgress.numericalValueChanged.addHandler(onLoadChange);
					_videoSource.loadTotal.numericalValueChanged.addHandler(onLoadChange);
					_videoSource.currentTime.numericalValueChanged.addHandler(onTimeChange);
					_videoSource.totalTime.numericalValueChanged.addHandler(onTimeChange);
					_slider.maximum = _videoSource.totalTime.numericalValue;
					_slider.value = _videoSource.currentTime.numericalValue;
				}
				invalidate();
			}
		}
		// TODO: fix this, it breaks the oldWidth & oldHeight dispatched with the change event
		override public function get measurements() : Point{
			return _slider.measurements;
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
			
			_playedBar = _containerAsset.takeAssetByName(PLAYED_BAR,IDisplayAsset,true);
			var cast:ISpriteAsset;
			if(_playedBar){
				cast = (_playedBar as ISpriteAsset);
				if(cast)cast.hitArea = _asset.createAsset(ISpriteAsset);
			}
			
			_bufferedBar = _containerAsset.takeAssetByName(BUFFERED_BAR,IDisplayAsset,true);
			if(_bufferedBar){
				cast = (_bufferedBar as ISpriteAsset);
				if(cast)cast.hitArea = _asset.createAsset(ISpriteAsset);
			}
		}
		override protected function unbindFromAsset() : void{
			var cast:ISpriteAsset;
			if(_playedBar){
				cast = (_playedBar as ISpriteAsset);
				if(cast)cast.hitArea = null;
			}
			
			if(_bufferedBar){
				cast = (_bufferedBar as ISpriteAsset);
				if(cast)cast.hitArea = null;
			}
			
			_slider.asset = null;
			_containerAsset.returnAsset(_playedBar);
			_playedBar = null;
			_containerAsset.returnAsset(_bufferedBar);
			_bufferedBar = null;
		}
		override protected function draw() : void{
			var playedFract:Number;
			if(_videoSource){
				var total:Number = _videoSource.totalTime.numericalValue;
				var progress:Number = _videoSource.currentTime.numericalValue;
				if(total>0){
					playedFract = (progress<total)?progress/total:1;
				}else{
					playedFract = 0;
				}
			}else{
				playedFract = 0;
			}
			if(_videoSource && total>0){
				playedFract = (progress<total)?progress/total:1;
			}else{
				playedFract = 0;
			}
			var loadFract:Number = (_videoSource?_videoSource.loadProgress.numericalValue/_videoSource.loadTotal.numericalValue:0);
			
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
		protected function onSliderMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		protected function onLoadChange(from:INumberProvider):void{
			invalidate();
		}
		protected function onTimeChange(from:INumberProvider):void{
			_slider.maximum = _videoSource.totalTime.numericalValue;
			_slider.value = _videoSource.currentTime.numericalValue
			invalidate();
		}
		protected function onPlayheadChange(from:Slider, value:Number):void{
			_videoSource.currentTime.numericalValue = value;
		}
	}
}