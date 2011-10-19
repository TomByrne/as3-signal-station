package org.tbyrne.compose.traits
{
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.concerns.ITraitConcern;

	public interface ITrait
	{
		function set item(value:org.tbyrne.compose.core.ComposeItem):void;
		function get item():ComposeItem;
		function get concerns():Vector.<ITraitConcern>;
	}
}