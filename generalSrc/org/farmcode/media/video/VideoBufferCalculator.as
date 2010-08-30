package org.farmcode.media.video
{
	import flash.net.NetStream;
	import flash.net.SharedObject;
	
	import org.farmcode.math.units.MemoryUnitConverter;
	import org.farmcode.math.units.UnitConverter;
	
	public class VideoBufferCalculator
	{
		
		public static const DEFAULT_SETTINGS_IDENTIFIER: String = "farm.videoSettings";
		public static const DEFAULT_SETTINGS_PATH: String = "/";
		
		// default large buffer (used when playing, if no duration can be found).
		private static const BIG_BUFFER:Number = 1000000;
		
		// default small buffer (used when playing, if no duration can be found).
		private static const SMALL_BUFFER:Number = 8;
		
		// default small buffer, as a percentage of the videos length (used if no recordings have been made in the SharedObject).
		private static const SMALL_BUFFER_PERCENT:Number = 0.05;
		
		// amount of additional seconds a user should wait for buffering to avoid the buffer emptying at the very end.
		private static const BUFFER_WAIT:Number = 1;
		
		// maximum amount of bitrate recordings to store in the SharedObject (old recordings get removed).
		private static const MAX_RECORDINGS:Number = 3;
		
		// minimum amount of time for a trusted datarate recording, in seconds.
		private static const MIN_RECORD_TIME:Number = 2;
		
		protected static var sharedObject:SharedObject;
		protected static var _videoSettingsIdentifier:String;
		protected static var _videoSettingsPath:String;
		
		public static function set videoSettingsIdentifier(value: String): void{
			if (videoSettingsIdentifier != value){
				_videoSettingsIdentifier = value;
				instantiateSharedData();
			}
		}
		public static function get videoSettingsIdentifier(): String{
			return _videoSettingsIdentifier;
		}
		
		
		public static function set videoSettingsPath(value: String): void{
			if (videoSettingsPath != value){
				_videoSettingsPath = value;
				instantiateSharedData();
			}
		}
		public static function get videoSettingsPath(): String{
			return _videoSettingsPath;
		}
		
		
		protected static function instantiateSharedData(): void{
			if(_videoSettingsIdentifier && _videoSettingsPath){
				sharedObject = SharedObject.getLocal(_videoSettingsIdentifier, _videoSettingsPath);
			}
		}
		
		/**
		 * Returns bandwidth in kilobytes/second
		 */
		public static function getBandwidth(_netStream:NetStream, timeSpendLoading:Number, byteOffset:Number):Number{
			if(_netStream.bytesLoaded){
				if (!sharedObject){
					videoSettingsIdentifier = DEFAULT_SETTINGS_IDENTIFIER;
					videoSettingsPath = DEFAULT_SETTINGS_PATH
				}
				
			
				var buffTime:Number = _netStream.time+_netStream.bufferLength;
				var totalTime:Number = (totalTime?totalTime:buffTime*((_netStream.bytesTotal-byteOffset)/(_netStream.bytesLoaded-byteOffset)));
				var bandwidth:Number;
				
				if(!sharedObject.data.videoRate)sharedObject.data.videoRate = [];
				var rates:Array = sharedObject.data.videoRate;
				if(timeSpendLoading && timeSpendLoading>=(MIN_RECORD_TIME*1000)){
					bandwidth = Math.round(toKilobits(_netStream.bytesLoaded/(timeSpendLoading/1000)));
					rates.push(bandwidth); // record current rate
				}
				while(rates.length>MAX_RECORDINGS)rates.shift();
				
				var count:Number = 0;
				bandwidth = 0;
				for(var i:int=0; i<rates.length; i++){
					bandwidth += rates[i]*(i+1);
					count += (i+1);
				}
				bandwidth /= count;
				return bandwidth;
			}
			return NaN;
		}
		
		public static function calcSmallBuffer(_netStream:NetStream, timeSpendLoading:Number, byteOffset:Number, combinedKbps:Number, totalTime:Number):Number{
			if(_netStream.bytesLoaded && !isNaN(byteOffset)){
				if(isNaN(combinedKbps) && !isNaN(totalTime))combinedKbps = UnitConverter.convert(_netStream.bytesTotal/totalTime,MemoryUnitConverter.BYTES,MemoryUnitConverter.KILOBYTES);
				
				var bandwidth:Number = getBandwidth(_netStream, timeSpendLoading, byteOffset);
				
				// NOTE: it adds one second of wait to make sure it doesn't run out right at the end.
				if(!isNaN(bandwidth) && bandwidth){
					var videoDataRate:Number = Math.max(_netStream.bytesTotal/totalTime,toBytes(combinedKbps)) // size of 1 second of video/audio (in bytes)
					//var kiloRate:Number = toKilobits(videoDataRate);
					var bytesRemaining:Number = (_netStream.bytesTotal-_netStream.bytesLoaded); // amount of bytes left to load
					var timeRemaining:Number = (totalTime-_netStream.time); // amount of video time left to load
					var offset:Number = (timeRemaining-BUFFER_WAIT)*toBytes(bandwidth); // amount of bytes that can be loaded in the remaining duration of the video (minus a constant to avoid an empty buffer at the near the end)
					var bufferTime:Number = Math.max((bytesRemaining-offset)/videoDataRate,BUFFER_WAIT);
					return bufferTime;
				}
			}else if(!isNaN(totalTime)){
				return totalTime*SMALL_BUFFER_PERCENT;
			}
			return SMALL_BUFFER;
		}
		public static function calcLargeBuffer(totalTime:Number):Number{
			return (!isNaN(totalTime) && totalTime?totalTime:BIG_BUFFER);
		}
		private static function toKilobits(bytes:Number):Number{
			return UnitConverter.convert(bytes,MemoryUnitConverter.BYTES,MemoryUnitConverter.KILOBITS);
		}
		private static function toBytes(kilobits:Number):Number{
			return UnitConverter.convert(kilobits,MemoryUnitConverter.KILOBITS,MemoryUnitConverter.BYTES);
		}
	}
}