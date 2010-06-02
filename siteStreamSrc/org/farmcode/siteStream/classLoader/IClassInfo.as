package org.farmcode.siteStream.classLoader
{
	public interface IClassInfo
	{
		function get classPath():String;
		function get libraryID():String;
		function set classRef(value:Class):void;
	}
}