package org.tbyrne.actLibrary.core
{
	import org.tbyrne.acting.actTypes.IAct;
	
	public interface IRevertableAct extends IAct
	{
		function get doRevert():Boolean;
		function get revertAct():IAct;
	}
}