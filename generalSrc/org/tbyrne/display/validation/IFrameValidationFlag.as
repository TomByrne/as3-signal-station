package org.tbyrne.display.validation
{
	import org.tbyrne.display.core.IView;

	public interface IFrameValidationFlag extends IView
	{
		function get valid():Boolean;
		function get readyForExecution():Boolean;
		function execute():void;
	}
}