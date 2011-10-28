package org.tbyrne.composeLibrary.tools.selection2d
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface ISelectable2dTrait extends ITrait
	{
		function setSelected(selected:Boolean):void;
		function setInterested(interested:Boolean):void;
	}
}