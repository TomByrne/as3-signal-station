package org.farmcode.sodalityPlatformEngine.parallax.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxItem;
	
	public interface IModifyParallaxItemAdvice extends IAdvice
	{
		function get x(): Number;
		function set x(value: Number): void;
		function get y(): Number;
		function set y(value: Number): void;
		function get z(): Number;
		function set z(value: Number): void;
		
		function get rotation(): Number;
		function set rotation(value: Number): void;
		
		function get item(): IParallaxItem;
	}
}