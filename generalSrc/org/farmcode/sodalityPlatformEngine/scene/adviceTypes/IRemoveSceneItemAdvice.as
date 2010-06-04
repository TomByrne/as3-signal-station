package org.farmcode.sodalityPlatformEngine.scene.adviceTypes
{
	import org.farmcode.sodalityPlatformEngine.scene.advice.ISceneItemAdvice;

	public interface IRemoveSceneItemAdvice extends ISceneItemAdvice
	{
		function get removeFromScene():Boolean;
	}
}