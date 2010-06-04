package org.farmcode.sodalityPlatformEngine.parallax
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	import au.com.thefarmdigital.parallax.Point3D;
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusOffsetItem;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	
	import flash.geom.Rectangle;
	
	public interface IParallaxItem extends ISceneItem, IFocusOffsetItem
	{
		function set position3D(value:Point3D):void;
		function get position3D():Point3D;
		function set rotation(value:Number):void;
		function get rotation():Number;
		function get parallaxDisplay():IParallaxDisplay;
		function get cullBounds():Rectangle;
	}
}