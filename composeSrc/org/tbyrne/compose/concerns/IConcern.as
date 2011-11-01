package org.tbyrne.compose.concerns
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.ITrait;

	public interface IConcern
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
		function get ascendants():Boolean;
		function get descendants():Boolean;
		function get acceptOwnerTrait():Boolean;
		
		function get ownerTrait():ITrait;
		function set ownerTrait(value:ITrait):void;
		
		function concernAdded(trait:ITrait):void;
		function concernRemoved(trait:ITrait):void;
		
		function shouldDescend(item:ComposeItem):Boolean;
	}
}