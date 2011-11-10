package org.tbyrne.compose.traits
{
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.compose.core.ComposeItem;

	public interface ITrait
	{
		function set item(value:org.tbyrne.compose.core.ComposeItem):void;
		function get item():ComposeItem;
		function get group():ComposeGroup;
		function get concerns():Vector.<IConcern>;
	}
}