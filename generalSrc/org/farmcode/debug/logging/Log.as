package org.farmcode.debug.logging
{
	public class Log
	{
		// The lower the level the more important (i.e. 0 is most important)
		public static const INFO:int 						= 3;
		public static const PERFORMANCE:int					= 2;
		public static const SUSPICIOUS_IMPLEMENTATION:int	= 1;
		public static const ERROR:int						= 0;
		
		public static var logger:ILogger = new NativeLogger();
		
		public static function setLogger(logger:ILogger):void{
			Log.logger = logger;
		}
		public static function log(level:int, ... params):void{
			logger.log(level,params);
		}
		public static function setVisibility(level:int):void{
			logger.setVisibility(level);
		}
		
		// Shortcuts
		public static function trace(... params):void{
			log.apply(null,[INFO].concat(params));
		}
		public static function error(... params):void{
			log.apply(null,[ERROR].concat(params));
		}
	}
}