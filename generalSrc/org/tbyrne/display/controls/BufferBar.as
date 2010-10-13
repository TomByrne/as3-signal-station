package org.tbyrne.display.controls
{
	
	import flash.geom.Point;
	
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.media.video.IVideoSource;
	
	use namespace DisplayNamespace;
	
	public class BufferBar extends Control
	{
		DisplayNamespace static const BUFFERED_BAR:String = "bufferedBar";
		
		
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
				invalidateSize();
			}
		}
		
		private var _videoSource:IVideoSource;
		private var _slider:Slider;
		private var _bufferedBar:IDisplayAsset;
		private var _track:IDisplayAsset;
		private var _thumb:IDisplayAsset;
		
		public function BufferBar(){
			super();
			_slider = new Slider();
			_slider.measurementsChanged.addHandler(onSliderMeasChange);
			_slider.valueChangedByUser.addHandler(onPlayheadChange);
		}
		override protected function bindToAsset() : void{
			_slider.asset = asset;
			
			_bufferedBar = _containerAsset.takeAssetByName(BUFFERED_BAR,IDisplayAsset,true);
			if(_bufferedBar){
				var cast:IInteractiveObjectAsset = (_bufferedBar as IInteractiveObjectAsset);
				if(cast)cast.mouseEnabled = false;
			}
			_track = _containerAsset.takeAssetByName(Slider.TRACK,IDisplayAsset);
			_thumb = _containerAsset.takeAssetByName(Slider.THUMB,IDisplayAsset);
		}
		override protected function unbindFromAsset() : void{
			
			if(_bufferedBar){
				var cast:IInteractiveObjectAsset = (_bufferedBar as IInteractiveObjectAsset);
				if(cast)cast.mouseEnabled = true;
				
				_containerAsset.returnAsset(_bufferedBar);
				_bufferedBar = null;
			}
			_containerAsset.returnAsset(_track);
			_track = null;
			_containerAsset.returnAsset(_thumb);
			_thumb = null;
			
			_slider.asset = null;
		}
		override protected function measure():void{
			_measurements.x = _slider.measurements.x;
			_measurements.y = _slider.measurements.y;
		}
		override public function setPosition(x:Number, y:Number) : void{
			super.setPosition(x,y);
			_slider.setPosition(x,y);
		}
		override public function setSize(width:Number, height:Number) : void{
			super.setSize(width,height);
			_slider.setSize(width,height);
		}
		override protected function validateSize():void{
			
			if(_bufferedBar){
				_slider.validate(); // this forces _track & _thumb to have the correct sizes
				
				var loadFract:Number;
				if(_videoSource){
					if(_videoSource.loadTotal.numericalValue>0){
						loadFract = _videoSource.loadProgress.numericalValue/_videoSource.loadTotal.numericalValue;
					}else{
						loadFract = 0;
					}
				}else{
					loadFract = 0;
				}
				
				
				var bufferX:Number;
				var bufferY:Number;
				var bufferW:Number;
				var bufferH:Number;
			
				if(_slider.direction==Direction.VERTICAL){
					var natWidth:Number = _bufferedBar.naturalWidth;
					if(natWidth<_track.width){
						bufferW = natWidth;
						bufferX = _track.x+(_track.width-natWidth)/2;
					}else{
						bufferW = _track.width;
						bufferX = _track.x;
					}
					bufferH = ((_track.height-_thumb.height)*loadFract)+_thumb.height;
					bufferY = _track.y;
				}else{
					var natHeight:Number = _bufferedBar.naturalHeight;
					if(natHeight<_track.height){
						bufferH = natHeight;
						bufferY = _track.y+(_track.height-natHeight)/2;
					}else{
						bufferH = _track.height;
						bufferY = _track.y;
					}
					bufferW = ((_track.width-_thumb.width)*loadFract)+_thumb.width;
					bufferX = _track.x;
				}
				_bufferedBar.setSizeAndPos(bufferX,bufferY,bufferW,bufferH);
			}
		}
		protected function onSliderMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			invalidateMeasurements();
		}
		protected function onLoadChange(from:INumberProvider):void{
			invalidateSize();
		}
		protected function onTimeChange(from:INumberProvider):void{
			_slider.maximum = _videoSource.totalTime.numericalValue;
			_slider.value = _videoSource.currentTime.numericalValue;
			invalidateSize();
		}
		protected function onPlayheadChange(from:Slider, value:Number):void{
			if(_videoSource)_videoSource.currentTime.numericalValue = value;
		}
	}
}