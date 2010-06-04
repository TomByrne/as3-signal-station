package org.farmcode.sodalityLibrary.display.visualSockets.socketContainers
{
	public class SocketContainerUtils
	{
		public static function getProperty(from:Object, prop:String):*{
			if(from==null){
				return null;
			}else if(prop=="*" || prop==null){
				return from;
			}else{
				var parts:Array = prop.split(".");
				while(parts.length){
					from = from[parts.shift()];
					if(!from)return null;
				}
				return from;
			}
		}
	}
}