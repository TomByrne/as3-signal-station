package org.farmcode.debug.logging
{
	public class Log
	{
		// The lower the level the more important (i.e. 0 is most important)
		public static const INFO:int 						= 3;
		public static const PERFORMANCE:int					= 2;
		public static const SUSPICIOUS_IMPLEMENTATION:int	= 1;
		public static const ERROR:int						= 0;
		
		private static var _logger:ILogger;
		private static var _visibility:int = -1;
		{
			CONFIG::debug{
				_logger = new NativeLogger();
			}
		}
		
		public static function setLogger(logger:ILogger):void{
			_logger = logger;
			if(_logger)_logger.setVisibility(_visibility);
		}
		public static function log(level:int, ... params):void{
			if(_logger)_logger.log(level,params);
		}
		public static function setVisibility(level:int):void{
			_visibility = level;
			if(_logger)_logger.setVisibility(_visibility);
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