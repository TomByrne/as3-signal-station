package org.tbyrne.display.validation
{
	import org.tbyrne.display.core.IView;

	public interface IFrameValidationFlag
	{
		function get valid():Boolean;
		function get readyForExecution():Boolean;
		function execute():void;
		
		/**
		 * returns true if the child param is a descendant of this flag
		 */
		function isDescendant(child:IFrameValidationFlag):Boolean;
		/**
		 * returns a key to this position n the hierarchy (usually a DisplayObject or equivilant).
		 */
		function get hierarchyKey():*;
	}
}