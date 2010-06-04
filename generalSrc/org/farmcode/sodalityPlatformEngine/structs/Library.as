package org.farmcode.sodalityPlatformEngine.structs
{
	import org.farmcode.siteStream.parsers.DefaultParser;
	import org.farmcode.siteStream.parsers.ISiteStreamParser;
	import org.farmcode.siteStream.propertyInfo.IPropertyInfo;
	import org.farmcode.siteStream.propertyInfo.PropertyInfo;
	
	public class Library extends DefaultParser
	{
		override public function set parentParser(value:ISiteStreamParser):void{
			super.parentParser = value;
		}
		public var items:Array;
		
		override public function parseLazily(propertyInfo:IPropertyInfo):Boolean{
			var castPropInfo:PropertyInfo = (propertyInfo as PropertyInfo);
			if(items && castPropInfo.parentObject==items){
				return true;
			}else{
				return super.parseLazily(propertyInfo);
			}
		}
	}
}