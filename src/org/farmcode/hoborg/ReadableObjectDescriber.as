package org.farmcode.hoborg
{
	import flash.utils.Dictionary;
	
	public class ReadableObjectDescriber
	{
		private static var describing:Dictionary;
		
		public static function describe(object:*):String{
			var root:Boolean;
			if(!describing){
				describing = new Dictionary(true);
				root = true;
			}
			var description:ObjectDescription = ObjectDescriber.describe(object);
			var props:String = "";
			if(!describing[object]){
				describing[object] = true;
				for each(var propDesc:ObjectPropertyDescription in description.properties){
					if (propDesc.toString)
					{
						props += " " + propDesc.propertyName + ":" + object[propDesc.propertyName];
					}
				}
			}
			if(root){
				describing = null;
			}
			return "["+description.className+props+"]";
		}

	}
}