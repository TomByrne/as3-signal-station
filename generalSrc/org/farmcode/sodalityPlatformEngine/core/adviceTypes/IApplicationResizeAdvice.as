package org.farmcode.sodalityPlatformEngine.core.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.geom.Rectangle;

	public interface IApplicationResizeAdvice extends IAdvice
	{
		function set appBounds(value:Rectangle):void;
		function get appBounds():Rectangle;
		function get appScale():Number;
	}
}