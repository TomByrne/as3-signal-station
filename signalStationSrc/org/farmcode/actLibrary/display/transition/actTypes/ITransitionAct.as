package org.farmcode.actLibrary.display.transition.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	
	public interface ITransitionAct extends IUniversalAct
	{
		function get doTransition():Boolean;
	}
}