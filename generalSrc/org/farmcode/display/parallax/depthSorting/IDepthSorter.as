package org.farmcode.display.parallax.depthSorting
{
	import org.farmcode.display.parallax.IParallaxDisplay;
	
	public interface IDepthSorter
	{
		function depthSort(item1:IParallaxDisplay, item2:IParallaxDisplay):Number;
	}
}