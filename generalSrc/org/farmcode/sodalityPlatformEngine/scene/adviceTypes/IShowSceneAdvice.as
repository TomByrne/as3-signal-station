package org.farmcode.sodalityPlatformEngine.scene.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.SceneDetails;

	public interface IShowSceneAdvice extends IAdvice
	{
		function get sceneDetails():SceneDetails;
		function get sceneDetailsPath():String;
	}
}