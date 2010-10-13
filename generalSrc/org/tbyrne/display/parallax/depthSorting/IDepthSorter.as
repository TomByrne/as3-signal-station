package org.tbyrne.display.parallax.depthSorting
{
	import org.tbyrne.display.parallax.IParallaxDisplay;
	
	public interface IDepthSorter
	{
		function depthSort(item1:IParallaxDisplay, item2:IParallaxDisplay):Number;
	}
}