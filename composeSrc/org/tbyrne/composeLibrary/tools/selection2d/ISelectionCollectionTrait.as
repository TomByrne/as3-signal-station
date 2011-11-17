package org.tbyrne.composeLibrary.tools.selection2d
{ 
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.controls.ISelectableCollection;

	public interface ISelectionCollectionTrait extends ITrait
	{
		function get selection():ISelectableCollection;
		function get interested():ISelectableCollection;
	}
}