package org.tbyrne.debug.logging
{
	public class ErrorLogger extends AbstractLogger implements ILogger
	{
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
							dispatchEvent(cast);
						}else{
							throw new Error(levelName+obj);
						}
					}
				}
			}
		}
	}
}