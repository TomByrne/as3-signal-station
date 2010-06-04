package org.farmcode.actLibrary.external.siteStream.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IReleasePathAct extends IUniversalAct
	{
		function get releasePath():String;
	}
}