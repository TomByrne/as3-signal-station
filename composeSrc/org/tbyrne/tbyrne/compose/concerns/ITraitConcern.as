package org.tbyrne.tbyrne.compose.concerns
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.tbyrne.compose.traits.ITrait;

	public interface ITraitConcern
	{
		
		/**
		 * handler(from:ITraitConcern, trait:ITrait)
		 */
		function get traitAdded():IAct;
		
		/**
		 * handler(from:ITraitConcern, trait:ITrait)
		 */
		function get traitRemoved():IAct;
		
		function get interestedTraitType():Class;
		function get siblings():Boolean;
		function get descendants():Boolean;
		
		function concernAdded(trait:ITrait):void;
		function concernRemoved(trait:ITrait):void;
		
		function shouldDescend(item:ComposeGroup):Boolean;
	}
}