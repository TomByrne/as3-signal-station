package org.tbyrne.actLibrary.external.siteStream.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IReleasePathAct extends IUniversalAct
	{
		function get releasePath():String;
	}
}