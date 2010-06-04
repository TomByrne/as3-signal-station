package org.farmcode.sodalityPlatformEngine.core.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.geom.Rectangle;

	public interface IRequestApplicationSizeAdvice extends IAdvice
	{
		function get appBounds():Rectangle;
		function set appBounds(value:Rectangle):void;
		function get appScale():Number;
		function set appScale(value:Number):void;
	}
}