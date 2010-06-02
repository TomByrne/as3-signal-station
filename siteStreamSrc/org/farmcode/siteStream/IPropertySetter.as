package org.farmcode.siteStream
{
	import org.farmcode.siteStream.propertyInfo.IPropertyInfo;
	
	import flash.events.IEventDispatcher;

	[Event(name="parsed",type="org.farmcode.siteStream.SiteStreamEvent")]
	public interface IPropertySetter extends IEventDispatcher
	{
		function set isReference(value:Boolean):void;
		function get isReference():Boolean;
		function get propertyInfo():IPropertyInfo;
		function get allParsed():Boolean;
		function set value(value:*):void;
		function addPropertyChild(child:IPropertySetter):void;
	}
}