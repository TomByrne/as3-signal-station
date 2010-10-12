package org.farmcode.debug.logging
{
	import flash.events.ErrorEvent;

	public class NativeLogger extends TraceLogger
	{
		private var LEVEL_NAMES:Array;
		private var _visibility:int = -1;
		
		
		public function NativeLogger():void{
		}
		override public function log(level:int, ... params):void{
			if(_visibility==-1 || level<=_visibility){
				var levelName:String = getLevelName(level);
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
	}
}