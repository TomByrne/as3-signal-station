package org.tbyrne.media
{
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.progress.IProgressDisplay;

	public class MediaProgressDisplayAdaptor
	{
		
		public function get mediaSource():IMediaSource{
			return _mediaSource;
		}
		public function set mediaSource(value:IMediaSource):void{
			if(_mediaSource!=value){
				if(_mediaSource){
					_mediaSource.loadProgress.numericalValueChanged.removeHandler(onProgressTotalChanged);
					_mediaSource.loadTotal.numericalValueChanged.removeHandler(onProgressTotalChanged);
				}
				_mediaSource = value;
				if(_mediaSource){
					_mediaSource.loadProgress.numericalValueChanged.addHandler(onProgressTotalChanged);
					_mediaSource.loadTotal.numericalValueChanged.addHandler(onProgressTotalChanged);
					_active.booleanValue = (_mediaSource.loadProgress.numericalValue<_mediaSource.loadTotal.numericalValue);
					if(_progressDisplay){
						_progressDisplay.progress = _mediaSource.loadProgress;
						_progressDisplay.total = _mediaSource.loadTotal;
						_progressDisplay.units = _mediaSource.loadUnits;
					}
				}else if(_progressDisplay){
					_progressDisplay.progress = null;
					_progressDisplay.total = null;
					_progressDisplay.units = null;
					_active.booleanValue = false;
				}
			}
		}
		
		public function get progressDisplay():IProgressDisplay{
			return _progressDisplay;
		}
		public function set progressDisplay(value:IProgressDisplay):void{
			if(_progressDisplay!=value){
				if(_progressDisplay){
					_progressDisplay.active = null;
					_progressDisplay.measurable = null;
					_progressDisplay.progress = null;
					_progressDisplay.total = null;
					_progressDisplay.units = null;
				}
				_progressDisplay = value;
				if(_progressDisplay){
					_progressDisplay.measurable = _measurable;
					_progressDisplay.active = _active;
					if(_mediaSource){
						_progressDisplay.progress = _mediaSource.loadProgress;
						_progressDisplay.total = _mediaSource.loadTotal;
						_progressDisplay.units = _mediaSource.loadUnits;
					}
				}
			}
		}
		
		private var _progressDisplay:IProgressDisplay;
		private var _mediaSource:IMediaSource;
		
		private var _measurable:BooleanData;
		private var _active:BooleanData;
		
		public function MediaProgressDisplayAdaptor(mediaSource:IMediaSource=null, progressDisplay:IProgressDisplay=null){
			_measurable = new BooleanData(true);
			_active = new BooleanData();
			
			this.mediaSource = mediaSource;
			this.progressDisplay = progressDisplay;
		}
		protected function onProgressTotalChanged(from:INumberProvider):void{
			_active.booleanValue = (_mediaSource.loadProgress.numericalValue<_mediaSource.loadTotal.numericalValue);
		}
	}
}