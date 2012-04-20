package org.tbyrne.siteStream.classLoader
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.core.IPendingResult;
	
	public interface IClassLoader
	{
		/**
		 * handler(from:IClassLoader)
		 */
		function get classLoadFailure():IAct;
		
		function isClassLoaded(classInfo:IClassInfo):Boolean;
		function loadClass(classInfo:IClassInfo):IPendingResult;
		function releaseClass(classInfo:IClassInfo):void;
	}
}