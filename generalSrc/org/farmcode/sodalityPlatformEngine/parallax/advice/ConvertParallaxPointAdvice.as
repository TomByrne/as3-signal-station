package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import au.com.thefarmdigital.parallax.Point3D;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IConvertParallaxPointAdvice;

	public class ConvertParallaxPointAdvice extends ConversionAdvice implements IConvertParallaxPointAdvice
	{
		public function ConvertParallaxPointAdvice(parallaxPoint:Point3D=null)
		{
			super();
			this.parallaxPoint = parallaxPoint;
		}
	}
}