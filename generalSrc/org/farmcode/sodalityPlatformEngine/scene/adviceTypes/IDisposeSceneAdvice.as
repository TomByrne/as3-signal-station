package org.farmcode.sodalityPlatformEngine.scene.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.SceneDetails;

	public interface IDisposeSceneAdvice extends IAdvice
	{
		function get sceneDetails(): SceneDetails;
	}
}