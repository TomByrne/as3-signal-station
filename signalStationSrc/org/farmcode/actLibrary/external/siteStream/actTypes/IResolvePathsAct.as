package org.farmcode.actLibrary.external.siteStream.actTypes
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IResolvePathsAct extends IUniversalAct
	{
		function get resolvePaths():Array;
		function set resolvedObjects(value:Dictionary):void;
		function set resolveSuccessful(value:Boolean):void;
	}
}