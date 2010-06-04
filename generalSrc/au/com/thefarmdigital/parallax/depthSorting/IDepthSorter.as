package au.com.thefarmdigital.parallax.depthSorting
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	
	public interface IDepthSorter
	{
		function depthSort(item1:IParallaxDisplay, item2:IParallaxDisplay):Number;
	}
}