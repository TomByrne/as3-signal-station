package org.farmcode.sodalityPlatformEngine.particles
{
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	
	import flash.geom.Rectangle;
	
	public interface IParticleScene extends IScene
	{
		/**
		 * If this returns NaN no Frustum Death Zone will be applied.
		 */
		function get frustumDeathPadding():Number;
		/**
		 * If this returns NaN no Frustum Death Zone will be applied.
		 */
		function get frustumDeathFarDistance():Number;
	}
}