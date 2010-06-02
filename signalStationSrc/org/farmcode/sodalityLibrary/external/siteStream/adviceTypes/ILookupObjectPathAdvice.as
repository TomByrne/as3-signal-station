package org.farmcode.sodalityLibrary.external.siteStream.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ILookupObjectPathAdvice extends IAdvice
	{
		function get lookupObject():Object;
		function set lookupObjectPath(value:String):void;
	}
}