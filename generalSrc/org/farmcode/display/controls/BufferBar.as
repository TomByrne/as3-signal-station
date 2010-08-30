package org.farmcode.display.controls
{
	
	import flash.geom.Point;
	
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.ILayoutSubject;
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
			var cast:IInteractiveObjectAsset;
			if(_playedBar){
				cast = (_playedBar as IInteractiveObjectAsset);
				if(cast)cast.mouseEnabled = false;
			}
			
			_bufferedBar = _containerAsset.takeAssetByName(BUFFERED_BAR,IDisplayAsset,true);
			if(_bufferedBar){
				cast = (_bufferedBar as IInteractiveObjectAsset);
				if(cast)cast.mouseEnabled = false;
			}
		}
		override protected function unbindFromAsset() : void{
			var cast:IInteractiveObjectAsset;
			if(_playedBar){
				cast = (_playedBar as IInteractiveObjectAsset);
				if(cast)cast.mouseEnabled = true;
			}
			
			if(_bufferedBar){
				cast = (_bufferedBar as IInteractiveObjectAsset);
				if(cast)cast.mouseEnabled = true;
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
			
			var playedX:Number;
			var playedY:Number;
			var playedW:Number;
			var playedH:Number;
			
			var bufferX:Number;
			var bufferY:Number;
			var bufferW:Number;
			var bufferH:Number;
			
			if(_slider.direction==Direction.VERTICAL){
				if(_playedBar){
					var natWidth:Number = _playedBar.width/_playedBar.scaleX;
					if(natWidth<displayPosition.width){
						playedW = natWidth;
						playedX = (displayPosition.width-natWidth)/2;
					}else{
						playedW = displayPosition.width;
						playedX = 0;
					}
					playedH = displayPosition.height*playedFract;
					playedY = 0;
				}
				
				if(_bufferedBar){
					natWidth = _bufferedBar.width/_bufferedBar.scaleX;
					if(natWidth<displayPosition.width){
						bufferW = natWidth;
						bufferX = (displayPosition.width-natWidth)/2;
					}else{
						bufferW = displayPosition.width;
						bufferX = 0;
					}
					bufferH = displayPosition.height*loadFract;
					bufferY = 0;
				}
			}else{
				if(_playedBar){
					var natHeight:Number = _playedBar.height/_playedBar.scaleY;
					if(natHeight<displayPosition.height){
						playedH = natHeight;
						playedY = (displayPosition.height-natHeight)/2;
					}else{
						playedH = displayPosition.height;
						playedY = 0;
					}
					playedW = displayPosition.width*playedFract;
					playedX = 0;
				}
				
				if(_bufferedBar){
					natHeight = _bufferedBar.height/_bufferedBar.scaleY;
					if(natHeight<displayPosition.height){
						bufferH = natHeight;
						bufferY = (displayPosition.height-natHeight)/2;
					}else{
						bufferH = displayPosition.height;
						bufferY = 0;
					}
					bufferW = displayPosition.width*loadFract;
					bufferX = 0;
				}
			}
			_bufferedBar.setSizeAndPos(bufferX,bufferY,bufferW,bufferH);
			_playedBar.setSizeAndPos(playedX,playedY,playedW,playedH);
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