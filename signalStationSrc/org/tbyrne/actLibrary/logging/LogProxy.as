package org.tbyrne.actLibrary.logging
{
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.debug.logging.ILogger;
	
	public class LogProxy extends UniversalActorHelper implements ILogger
	{
		protected var _logAct:LogAct = new LogAct();
		
		public function LogProxy(){
			addChild(_logAct);
			
			metadataTarget = this;
		}
		
		public function log(level:int, ...params):void{
			_logAct.level = level;
			_logAct.params = params;
			_logAct.perform();
		}
	}
}