package org.tbyrne.tbyrne.compose.traits
{
	import org.tbyrne.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.tbyrne.compose.concerns.ITraitConcern;

	public interface ITrait
	{
		function set item(value:org.tbyrne.tbyrne.compose.core.ComposeItem):void;
		function get item():ComposeItem;
		function get concerns():Vector.<ITraitConcern>;
	}
}