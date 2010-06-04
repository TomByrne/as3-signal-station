package org.farmcode.media
{
	import org.farmcode.display.progress.IProgressDisplay;

	public class MediaProgressDisplayAdaptor
	{
		
		public function get mediaSource():IMediaSource{
			return _mediaSource;
		}
		public function set mediaSource(value:IMediaSource):void{
			if(_mediaSource!=value){
				if(_mediaSource){
					_mediaSource.loadProgressChanged.removeHandler(onProgressChange);
					_mediaSource.loadTotalChanged.removeHandler(onTotalChange);
				}
				_mediaSource = value;
				if(_mediaSource){
					_mediaSource.loadProgressChanged.addHandler(onProgressChange);
					_mediaSource.loadTotalChanged.addHandler(onTotalChange);
					if(_progressDisplay){
						_progressDisplay.measurable = true;
						_progressDisplay.progress = _mediaSource.loadProgress;
						_progressDisplay.total = _mediaSource.loadTotal;
						_progressDisplay.units = _mediaSource.loadUnits;
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
						_progressDisplay.progress = _mediaSource.loadProgress;
						_progressDisplay.total = _mediaSource.loadTotal;
						_progressDisplay.units = _mediaSource.loadUnits;
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
		protected function onProgressChange(from:IMediaSource):void{
			_progressDisplay.progress = from.loadProgress;
			_progressDisplay.units = _mediaSource.loadUnits;
		}
		protected function onTotalChange(from:IMediaSource):void{
			_progressDisplay.total = from.loadTotal;
		}
	}
}