package org.tbyrne.utils
{
	public class ObjectUtils
	{
		public static function getProperty(from:Object, prop:String):*{
			if(from==null){
				return null;
			}else if(prop=="*" || prop==null){
				return from;
			}else{
				var parts:Array = prop.split(".");
				for(var i:int=0; i<parts.length; i++){
					from = from[parts[i]];
					if(!from)return null;
				}
				return from;
			}
		}
		public static function setProperty(into:Object, prop:String, value:*):void{
			var parts:Array = prop.split(".");
			for(var i:int=0; i<parts.length-1; i++){
				into = into[parts[i]];
			}
			into[parts[i]] = value;
		}
	}
}