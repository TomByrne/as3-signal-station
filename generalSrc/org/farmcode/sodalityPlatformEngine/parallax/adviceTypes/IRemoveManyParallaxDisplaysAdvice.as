package org.farmcode.sodalityPlatformEngine.parallax.adviceTypes
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IRemoveManyParallaxDisplaysAdvice extends IAdvice
	{
		function get parallaxDisplays():Array;
	}
}