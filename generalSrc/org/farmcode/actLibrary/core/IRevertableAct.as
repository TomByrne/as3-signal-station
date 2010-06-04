package org.farmcode.actLibrary.core
{
	import org.farmcode.acting.actTypes.IAct;
	
	public interface IRevertableAct extends IAct
	{
		function get doRevert():Boolean;
		function get revertAct():IAct;
	}
}