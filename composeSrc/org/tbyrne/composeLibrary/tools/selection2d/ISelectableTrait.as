package org.tbyrne.composeLibrary.tools.selection2d
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface ISelectableTrait extends ITrait
	{
		/**
		 * handler(from:ISelectable2dTrait)
		 */
		function get selectedChanged():IAct;
		function get selected():Boolean;
		function set selected(selected:Boolean):void;
		
		/**
		 * handler(from:ISelectable2dTrait)
		 */
		function get interestedChanged():IAct;
		function get interested():Boolean;
		function set interested(interested:Boolean):void;
	}
}