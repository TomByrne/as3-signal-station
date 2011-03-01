package org.tbyrne.debug.logging
{
	
	
	public class TraceLogger extends AbstractLogger implements ILogger
	{
		
		
		public function TraceLogger():void{
		}
		public function log(level:int, ... params):void{
			var levelName:String = getLevelName(level);
			trace.apply(null,[levelName].concat(params));
		}
	}
}