package org.farmcode.sodalityPlatformEngine.parallax.adviceTypes
{
	import au.com.thefarmdigital.parallax.Point3D;
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.geom.Point;
	
	/**
	 * This converts a screen point to a parallax point. If no screenDepth is specified
	 * the depth of the object which falls under the point is used.
	 */
	public interface IConvertScreenPointAdvice extends IAdvice
	{
		function get screenPoint():Point;
		function get screenDepth():Number;
		function set parallaxPoint(value:Point3D):void;
		function get parallaxPoint():Point3D;
	}
}