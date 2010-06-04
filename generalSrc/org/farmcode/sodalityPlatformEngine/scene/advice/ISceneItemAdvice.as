package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	
	public interface ISceneItemAdvice extends IRevertableAdvice
	{
		function get sceneItem(): ISceneItem;
		//function get sceneItemPath(): String;
	}
}