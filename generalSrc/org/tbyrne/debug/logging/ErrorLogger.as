package org.tbyrne.debug.logging
{
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;

	public class ErrorLogger extends AbstractLogger implements ILogger
	{
		private var _eventDispatcher:EventDispatcher;
		
		public function ErrorLogger()
		{
		}
		
		public function log(level:int, ... params):void{
			var levelName:String = getLevelName(level);
			for each(var obj:* in params){
				if(obj is Error){
					throw obj;
				}else{
					var cast:ErrorEvent = (obj as ErrorEvent);
					if(cast){
						if(!_eventDispatcher){
							_eventDispatcher = new EventDispatcher();
						}
						_eventDispatcher.dispatchEvent(cast);
					}else{
						throw new Error(levelName+obj);
					}
				}
			}
		}
	}
}