package org.tbyrne.actLibrary.application.states.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IMoveInStateHistoryAct extends IUniversalAct
	{
		function get steps():int;
	}
}