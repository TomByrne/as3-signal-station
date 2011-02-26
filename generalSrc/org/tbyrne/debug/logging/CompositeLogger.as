package org.tbyrne.debug.logging
{
	public class CompositeLogger implements ILogger
	{
		public var loggers:Array;
		
		public function CompositeLogger(... loggers)
		{
			this.loggers = loggers;
		}
		
		public function log(level:int, ...params):void
		{
			var args:Array = [level].concat(params);
			for each(var logger:ILogger in loggers){
				logger.log.apply(null,args);
			}
		}
	}
}