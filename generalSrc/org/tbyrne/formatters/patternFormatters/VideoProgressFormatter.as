package org.tbyrne.formatters.patternFormatters
{
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.expressions.ParameterisedExpression;
	import org.tbyrne.data.operators.StringProxy;
	import org.tbyrne.math.units.TimeUnitConverter;
	import org.tbyrne.math.units.UnitConverter;
	import org.tbyrne.media.video.IVideoSource;

	public class VideoProgressFormatter extends AbstractPatternFormatter
	{
		static private const PLAYED_TIME:String 	= "${pt}";
		static private const REMAINING_TIME:String 	= "${rt}";
		static private const TOTAL_TIME:String 		= "${tt}";
		static private const LOADED_SIZE:String 	= "${ls}";
		static private const TOTAL_SIZE:String 		= "${ts}";
		static private const PERCENT_SIZE:String 	= "${ps}";
		static private const SIZE_UNITS:String 		= "${su}";
		
		public function get videoSource():IVideoSource{
			return _videoSource;
		}
		public function set videoSource(value:IVideoSource):void{
			if(_videoSource!=value){
				_videoSource = value;
				if(_videoSource){
					_loadedMemoryProxy.stringProvider = _videoSource.loadProgress;
					_totalMemoryProxy.stringProvider = _videoSource.loadTotal;
					_sizeUnitsProxy.stringProvider = _videoSource.loadUnits;
					
					_remainingTimeProxy.setParamProvider(_videoSource.currentTime,0);
					_remainingTimeProxy.setParamProvider(_videoSource.totalTime,1);
					
					_playedTimeProxy.setParamProvider(_videoSource.currentTime,0);
					_totalTimeProxy.setParamProvider(_videoSource.totalTime,0);
					_percentMemoryProxy.setParamProvider(_videoSource.loadProgress,0);
					_percentMemoryProxy.setParamProvider(_videoSource.loadTotal,1);
				}else{
					_loadedMemoryProxy.stringProvider = null;
					_totalMemoryProxy.stringProvider = null;
					_sizeUnitsProxy.stringProvider = null;
					
					_remainingTimeProxy.clearParamProvider(0);
					_remainingTimeProxy.clearParamProvider(1);
					
					_playedTimeProxy.clearParamProvider(0);
					_totalTimeProxy.clearParamProvider(0);
					_percentMemoryProxy.clearParamProvider(0);
					_percentMemoryProxy.clearParamProvider(1);
				}
			}
		}
		
		private var _videoSource:IVideoSource;
		private var _playedTimeProxy:ParameterisedExpression;
		private var _remainingTimeProxy:ParameterisedExpression;
		private var _totalTimeProxy:ParameterisedExpression;
		private var _loadedMemoryProxy:StringProxy;
		private var _totalMemoryProxy:StringProxy;
		private var _percentMemoryProxy:ParameterisedExpression;
		private var _sizeUnitsProxy:StringProxy;
		
		public function VideoProgressFormatter(videoSource:IVideoSource, pattern:IStringProvider){
			super(pattern);
			_addToken(PLAYED_TIME,_playedTimeProxy = new ParameterisedExpression(formatSeconds,1));
			_addToken(REMAINING_TIME,_remainingTimeProxy = new ParameterisedExpression(remainingTime,2));
			_addToken(TOTAL_TIME,_totalTimeProxy = new ParameterisedExpression(formatSeconds,1));
			_addToken(LOADED_SIZE,_loadedMemoryProxy = new StringProxy());
			_addToken(TOTAL_SIZE,_totalMemoryProxy = new StringProxy());
			_addToken(PERCENT_SIZE,_percentMemoryProxy = new ParameterisedExpression(calcPercent,2));
			_addToken(SIZE_UNITS,_sizeUnitsProxy = new StringProxy());
			this.videoSource = videoSource;
		}
		protected function remainingTime(currTime:Number, totalTime:Number):String{
			return formatSeconds(totalTime-currTime);
		}
		protected function formatSeconds(value:Number):String{
			var breakdown:Array = UnitConverter.breakdown(value,TimeUnitConverter.SECONDS,[TimeUnitConverter.HOURS,TimeUnitConverter.MINUTES,TimeUnitConverter.SECONDS]);
			var ret:String = "";
			var pad:Boolean;
			if(breakdown[0]>0){
				ret += String(breakdown[0])+":";
				pad = true;
			}
			var mins:String = String(breakdown[1]);
			if(pad && mins.length==1){
				mins = "0"+mins;
			}
			ret += mins+":";
			var seconds:String = String(breakdown[2]);
			if(seconds.length==1){
				seconds = "0"+seconds;
			}
			ret += seconds;
			return ret;
		}
		protected function calcPercent(progress:Number, total:Number):Number{
			return int(((progress/total)*100)+0.5);
		}
	}
}