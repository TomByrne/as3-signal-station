package org.tbyrne.siteStream.serialiser
{
	import flash.utils.Dictionary;

	public interface ITypeRules
	{
		function get allowTypeAsLiteral():Boolean; // of Strings
		function get ignoreProps():Array; // of Strings
		function get hexNumberProps():Array; // of Strings
		function get defaultProps():Dictionary;
		
		function doSerialise(object:*):Boolean;
	}
}