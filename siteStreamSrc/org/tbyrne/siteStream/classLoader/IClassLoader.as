package org.tbyrne.siteStream.classLoader
{
	import flash.events.IEventDispatcher;
	
	import org.tbyrne.core.IPendingResult;
	
	[Event(name="classFailure",type="org.tbyrne.siteStream.events.SiteStreamErrorEvent")]
	public interface IClassLoader extends IEventDispatcher
	{
		function isClassLoaded(classInfo:IClassInfo):Boolean;
		function loadClass(classInfo:IClassInfo):IPendingResult;
		function releaseClass(classInfo:IClassInfo):void;
	}
}