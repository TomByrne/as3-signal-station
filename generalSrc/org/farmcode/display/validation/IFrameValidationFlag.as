package org.farmcode.display.validation
{
	import org.farmcode.display.core.IView;

	public interface IFrameValidationFlag extends IView
	{
		function get valid():Boolean;
		function get readyForExecution():Boolean;
		function execute():void;
	}
}