package org.farmcode.sodalityLibrary.display.popUp.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.display.DisplayObject;
	
	public interface IRemovePopUpAdvice extends IAdvice
	{
		function get display():DisplayObject;
	}
}