package org.farmcode.sodalityPlatformEngine.scene.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	
	public interface ISceneRenderAdvice extends IAdvice
	{
		function get scene(): IScene;
		function get forceRender():Boolean;
	}
}