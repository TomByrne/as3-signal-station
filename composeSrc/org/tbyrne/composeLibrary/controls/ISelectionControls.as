package org.tbyrne.composeLibrary.controls
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectable2dTrait;

	public interface ISelectionControls
	{
		
		/**
		 * handler(from:ISelectionControls)
		 */
		function get selectionChanged():IAct;
		function get selection():Vector.<ISelectable2dTrait>;
		
		function selectAll():void;
		function deselectAll():void;
	}
}