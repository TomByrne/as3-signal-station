package org.tbyrne.actLibrary.external.siteStream.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ILookupObjectPathAct extends IUniversalAct
	{
		function get lookupObject():Object;
		function set lookupObjectPath(value:String):void;
	}
}