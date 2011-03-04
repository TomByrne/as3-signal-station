package 
{
	import flash.utils.Dictionary;
	import org.tbyrne.debug.logging.ErrorLogger;
	import org.tbyrne.debug.logging.ILogger;
	import org.tbyrne.debug.logging.TraceLogger;

	public class Log
	{
		// The lower the level the more important (i.e. 0 is most important)
		public static const USER_INFO:int 					= 6;
		public static const USER_ERROR:int 					= 5;
		public static const DEV_INFO:int 					= 4;
		public static const PERFORMANCE:int					= 3;
		public static const SUSPICIOUS_IMPLEMENTATION:int	= 2;
		public static const EXT_ERROR:int					= 1;
		public static const DEV_ERROR:int					= 0;
		
		public static var ALL_LEVELS:Array;
		
		private static var _loggers:Dictionary = new Dictionary();
		{
			ALL_LEVELS = [DEV_ERROR,
				EXT_ERROR,
				SUSPICIOUS_IMPLEMENTATION,
				PERFORMANCE,
				DEV_INFO,
				USER_ERROR,
				USER_INFO];
			
			CONFIG::debug{
				setLogger(new TraceLogger(),USER_INFO,USER_ERROR,DEV_INFO,PERFORMANCE,SUSPICIOUS_IMPLEMENTATION);
				setLogger(new ErrorLogger(),DEV_ERROR,EXT_ERROR);
			}
		}
		
		public static function setLogger(logger:ILogger, ... levels):void{
			if(!levels.length){
				levels = ALL_LEVELS;
			}
			var level:int;
			if(logger){
				for each(level in levels){
					_loggers[level] = logger;
				}
			}else{
				for each(level in levels){
					delete _loggers[level];
				}
			}
		}
		public static function log(level:int, ... params):void{
			var logger:ILogger = _loggers[level];
			if(logger){
				logger.log.apply(null,[level].concat(params));
			}
		}
		
		// Shortcuts
		public static function trace(... params):void{
			log.apply(null,[DEV_INFO].concat(params));
		}
		public static function error(... params):void{
			log.apply(null,[DEV_ERROR].concat(params));
		}
	}
}