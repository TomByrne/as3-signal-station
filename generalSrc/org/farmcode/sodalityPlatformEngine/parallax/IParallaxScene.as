package org.farmcode.sodalityPlatformEngine.parallax
{
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public interface IParallaxScene extends IScene
	{
		function get cullBuffer():Rectangle;
	}
}