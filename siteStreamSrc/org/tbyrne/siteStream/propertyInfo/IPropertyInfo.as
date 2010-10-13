package org.tbyrne.siteStream.propertyInfo
{
	public interface IPropertyInfo
	{
		//function get data():XML;
		function get propertyName():*;
		function get value():*;
		function set value(value:*):void;
		function set initialValue(value:*):void;
		function get valueSet():Boolean;
		function get useNode():Boolean;
		function get isNodeProperty():Boolean;
		function get isObjectProperty():Boolean;
		function get isWriteOnly():Boolean;
	}
}