package org.tbyrne.actLibrary.display.transition.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	
	public interface ITransitionAct extends IUniversalAct
	{
		function get doTransition():Boolean;
	}
}