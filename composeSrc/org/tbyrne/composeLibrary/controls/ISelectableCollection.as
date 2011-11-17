package org.tbyrne.composeLibrary.controls
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectableTrait;

	public interface ISelectableCollection
	{
		
		/**
		 * handler(from:ISelectionControls)
		 */
		function get collectionChanged():IAct;
		function get list():Vector.<ISelectableTrait>;
		
		function addAll():void;
		function removeAll():void;
		
		function add(trait:ISelectableTrait, addToCurrent:Boolean):void;
		function remove(trait:ISelectableTrait):void;
	}
}