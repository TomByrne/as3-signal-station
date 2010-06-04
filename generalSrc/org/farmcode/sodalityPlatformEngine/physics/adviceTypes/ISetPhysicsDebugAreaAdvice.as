package org.farmcode.sodalityPlatformEngine.physics.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.display.Sprite;

	public interface ISetPhysicsDebugAreaAdvice extends IAdvice
	{
		function get debugArea(): Sprite;
	}
}