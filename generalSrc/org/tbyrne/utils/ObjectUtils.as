package org.tbyrne.utils
{
	import org.tbyrne.reflection.ReflectionUtils;

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
		
		CONFIG::debug{
		
		public static function diffObjects(obj1:*, obj2:*):String{
			var typeObj1:String = (obj1==null || isNaN(obj1)?null:typeof(obj1));
			var typeObj2:String = (obj2==null || isNaN(obj2)?null:typeof(obj2));
			
			if(typeObj1 == typeObj2){
				switch(typeObj1){
					case "object":
					case "xml":
						var classErr:String;
						var class1:Class = obj1["constructor"];
						var class2:Class = obj2["constructor"];
						if(class1!=class2){
							classErr = "Different classes";
						}
						var children:String;
						for(var i:String in obj1){
							var childRet:String = diffObjects(obj1[i],obj2[i]);
							if(childRet){
								if(!children) children = "";
								children += i+": "+childRet.replace(/\n|\r|^/g,"\n\t");
							}
						}
						if(classErr){
							if(children){
								return classErr+":\n"+children
							}else{
								return classErr;
							}
						}else if(children){
							return children;
						}
						break;
					case "string":
						if(obj1!=obj2){
							return "Strings don't match ("+obj1+", "+obj2+")";
						}
						break;
					case "number":
						if(obj1!=obj2){
							return "Strings don't match ("+obj1+", "+obj2+")";
						}
						break;
					case "boolean":
						if(obj1!=obj2){
							return "Booleans don't match";
						}
						break;
				}
			}else{
				return "Different struct types ("+typeObj1+", "+typeObj2+")";
			}
			return null;
		}
			
		}
	}
}