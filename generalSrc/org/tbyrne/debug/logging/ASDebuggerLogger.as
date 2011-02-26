package org.tbyrne.debug.logging
{
	import nl.flexperiments.debug.ASDebugger;

	public class ASDebuggerLogger extends AbstractLogger implements ILogger
	{
		public function ASDebuggerLogger()
		{
			super();
		}
		
		public function log(level:int, ...params):void{
			var levelName:String = getLevelName(level);
			ASDebugger.apply(null,[levelName].concat(params).join(" ");
		}
	}
}