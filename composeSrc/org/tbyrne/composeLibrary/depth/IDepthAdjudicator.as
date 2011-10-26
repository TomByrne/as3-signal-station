package org.tbyrne.composeLibrary.depth
{
	import org.tbyrne.compose.traits.ITrait;

	public interface IDepthAdjudicator
	{
		function compare(trait1:ITrait, trait2:ITrait):int;
	}
}