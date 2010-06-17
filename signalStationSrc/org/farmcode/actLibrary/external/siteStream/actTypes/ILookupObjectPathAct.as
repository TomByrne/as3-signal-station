package org.farmcode.actLibrary.external.siteStream.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ILookupObjectPathAct extends IUniversalAct
	{
		function get lookupObject():Object;
		function set lookupObjectPath(value:String):void;
	}
}