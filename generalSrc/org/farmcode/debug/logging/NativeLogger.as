package org.farmcode.debug.logging
{
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class NativeLogger extends EventDispatcher implements ILogger
	{
		private var LEVEL_NAMES:Array;
		private var _visibility:int = -1;
		
		
		public function NativeLogger():void{
		}
		public function log(level:int, ... params):void{
			if(!LEVEL_NAMES){
				LEVEL_NAMES = [];
				LEVEL_NAMES[Log.INFO] = "INFO: ";
				LEVEL_NAMES[Log.PERFORMANCE] = "PERFORMANCE: ";
				LEVEL_NAMES[Log.SUSPICIOUS_IMPLEMENTATION] = "SUSPICIOUS: ";
				LEVEL_NAMES[Log.ERROR] = "ERROR: ";
			}
			if(_visibility==-1 || level<_visibility){
				var levelName:String = LEVEL_NAMES[level];
				if(level==Log.ERROR){
					for each(var obj:* in params){
						if(obj is Error){
							throw obj;
						}else{
							var cast:ErrorEvent = (obj as ErrorEvent);
							if(cast){
								dispatchEvent(cast);
							}else{
								throw new Error(levelName+obj);
							}
						}
					}
				}else{
					trace.apply(null,[levelName].concat(params));
				}
			}
		}
		public function setVisibility(level:int):void{
			_visibility = level;
		}
	}
}