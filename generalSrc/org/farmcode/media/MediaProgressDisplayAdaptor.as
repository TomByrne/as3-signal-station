package org.farmcode.media
{
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.display.progress.IProgressDisplay;

	public class MediaProgressDisplayAdaptor
	{
		
		public function get mediaSource():IMediaSource{
			return _mediaSource;
		}
		public function set mediaSource(value:IMediaSource):void{
			if(_mediaSource!=value){
				if(_mediaSource){
					_mediaSource.loadProgress.numericalValueChanged.removeHandler(onProgressChange);
					_mediaSource.loadTotal.numericalValueChanged.removeHandler(onTotalChange);
					_mediaSource.loadUnits.stringValueChanged.removeHandler(onUnitsChange);
				}
				_mediaSource = value;
				if(_mediaSource){
					_mediaSource.loadProgress.numericalValueChanged.addHandler(onProgressChange);
					_mediaSource.loadTotal.numericalValueChanged.addHandler(onTotalChange);
					_mediaSource.loadUnits.stringValueChanged.addHandler(onUnitsChange);
					if(_progressDisplay){
						_progressDisplay.measurable = true;
						_progressDisplay.progress = _mediaSource.loadProgress.numericalValue;
						_progressDisplay.total = _mediaSource.loadTotal.numericalValue;
						_progressDisplay.units = _mediaSource.loadUnits.stringValue;
					}
				}
			}
		}
		
		public function get progressDisplay():IProgressDisplay{
			return _progressDisplay;
		}
		public function set progressDisplay(value:IProgressDisplay):void{
			if(_progressDisplay!=value){
				_progressDisplay = value;
				if(_progressDisplay){
					if(_mediaSource){
						_progressDisplay.measurable = true;
						_progressDisplay.progress = _mediaSource.loadProgress.numericalValue;
						_progressDisplay.total = _mediaSource.loadTotal.numericalValue;
						_progressDisplay.units = _mediaSource.loadUnits.stringValue;
					}
				}
			}
		}
		
		private var _progressDisplay:IProgressDisplay;
		private var _mediaSource:IMediaSource;
		
		public function MediaProgressDisplayAdaptor(mediaSource:IMediaSource=null, progressDisplay:IProgressDisplay=null){
			this.mediaSource = mediaSource;
			this.progressDisplay = progressDisplay;
		}
		protected function onProgressChange(from:INumberProvider):void{
			_progressDisplay.progress = _mediaSource.loadProgress.numericalValue;
		}
		protected function onTotalChange(from:INumberProvider):void{
			_progressDisplay.total = _mediaSource.loadTotal.numericalValue;
		}
		protected function onUnitsChange(from:IStringProvider):void{
			_progressDisplay.units = _mediaSource.loadUnits.stringValue;
		}
	}
}