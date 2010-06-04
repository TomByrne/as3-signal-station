package org.farmcode.sodalityPlatformEngine.parallax.adviceTypes
{
	import au.com.thefarmdigital.parallax.Point3D;
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.geom.Point;

	public interface IConvertParallaxPointAdvice extends IAdvice
	{
		function get parallaxPoint():Point3D;
		function set screenPoint(value:Point):void;
		function get screenPoint():Point;
		function set screenDepth(value:Number):void;
		function get screenDepth():Number;
	}
}