package org.farmcode.siteStream.classLoader
{
	import flash.events.IEventDispatcher;
	
	import org.farmcode.core.IPendingResult;
	
	[Event(name="classFailure",type="org.farmcode.siteStream.events.SiteStreamErrorEvent")]
	public interface IClassLoader extends IEventDispatcher
	{
		function isClassLoaded(classInfo:IClassInfo):Boolean;
		function loadClass(classInfo:IClassInfo):IPendingResult;
		function releaseClass(classInfo:IClassInfo):void;
	}
}