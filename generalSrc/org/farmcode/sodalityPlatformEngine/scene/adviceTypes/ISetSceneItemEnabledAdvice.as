package org.farmcode.sodalityPlatformEngine.scene.adviceTypes
{
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;

	public interface ISetSceneItemEnabledAdvice extends IRevertableAdvice
	{
		function get sceneItem(): ISceneItem;
		function get enabled(): Boolean;
	}
}