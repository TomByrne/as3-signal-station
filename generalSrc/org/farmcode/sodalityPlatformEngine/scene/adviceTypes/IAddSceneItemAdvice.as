package org.farmcode.sodalityPlatformEngine.scene.adviceTypes
{
	import org.farmcode.sodalityPlatformEngine.scene.advice.ISceneItemAdvice;
	
	public interface IAddSceneItemAdvice extends ISceneItemAdvice
	{
		function get addToScene():Boolean
	}
}