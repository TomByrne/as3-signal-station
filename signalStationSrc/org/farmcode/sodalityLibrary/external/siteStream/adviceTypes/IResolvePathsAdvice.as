package org.farmcode.sodalityLibrary.external.siteStream.adviceTypes
{
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.IAdvice;

	public interface IResolvePathsAdvice extends IAdvice
	{
		function get resolvePaths():Array;
		function set resolvedObjects(value:Dictionary):void;
	}
}