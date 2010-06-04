package org.farmcode.sodalityPlatformEngine.scene.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.SceneDetails;
	
	public interface IRetrieveCurrentSceneAdvice extends IAdvice
	{
		function set sceneDetails(scene: SceneDetails): void;
		function set sceneDetailsPath(scenePath: String): void;
	}
}