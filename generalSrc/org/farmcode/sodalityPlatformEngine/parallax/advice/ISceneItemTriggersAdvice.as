package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import org.farmcode.sodalityPlatformEngine.scene.advice.ISceneItemAdvice;
	
	import flash.utils.Dictionary;
	
	public interface ISceneItemTriggersAdvice extends ISceneItemAdvice
	{
		function get eventTriggeredAdvice(): Dictionary;
		function get eventTargetProp(): String;
	}
}