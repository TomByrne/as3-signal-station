package org.farmcode.sodalityPlatformEngine.parallax.adviceTypes
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IAddManyParallaxDisplaysAdvice extends IAdvice
	{
		function get parallaxDisplays():Array;
	}
}