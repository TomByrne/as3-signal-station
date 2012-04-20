package org.tbyrne.siteStream
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;

	public interface IPropertySetter
	{
		
		/**
		 * handler(from:IPropertySetter)
		 */
		function get wasParsed():IAct;
		
		/**
		 * handler(from:IPropertySetter)
		 */
		function get wasResolved():IAct;
		
		function set isReference(value:Boolean):void;
		function get isReference():Boolean;
		function get propertyInfo():IPropertyInfo;
		function get allParsed():Boolean;
		function get allResolved():Boolean;
		function set value(value:*):void;
		function addPropertyChild(child:IPropertySetter):void;
		
		function checkAllParsed():void;
	}
}