package org.farmcode.sodalityLibrary.display.popUp.adviceTypes
{
	import flash.display.DisplayObject;
	
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	
	public interface IAddPopUpAdvice extends IRevertableAdvice
	{
		function get display():DisplayObject;
		function get modal():Boolean;
	}
}