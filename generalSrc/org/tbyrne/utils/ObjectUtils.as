package org.tbyrne.utils
{
	import flash.utils.Dictionary;

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
		public static function equals(obj1:Object, obj2:Object):Boolean{
			if(obj1==null){
				if(obj2==null){
					return true;
				}else{
					return false;
				}
			}else if(obj2==null){
				return false;
			}
			
			var done:Dictionary = new Dictionary();
			for(var i:* in obj1){
				done[i] = true;
				var value1:* = obj1[i];
				var value2:* = obj2[i];
				if(typeof(value1)=="object"){
					if(!equals(value1,value2)){
						return false;
					}
				}else{
					if(value1!=value2){
						return false;
					}
				}
			}
			for(i in obj2){
				if(!done[i]){
					return false;
				}
			}
			return true;
		}
	}
}