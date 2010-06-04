package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IAddSceneItemTriggersAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	
	import flash.utils.Dictionary;

	public class AddSceneItemTriggersAdvice extends SceneItemTriggersAdvice
		implements IAddSceneItemTriggersAdvice
	{		
		public function AddSceneItemTriggersAdvice(sceneItemId:String=null, sceneItem:ISceneItem=null,
			eventTriggers: Dictionary = null, eventTargetProp: String = null)
		{
			super(sceneItemId, sceneItem, eventTriggers, eventTargetProp);
		}
		
		override public function get revertAdvice(): Advice
		{
			return new RemoveSceneItemTriggersAdvice(_sceneItemPath, this.sceneItem, 
				this.eventTriggeredAdvice, this.eventTargetProp);
		}
	}
}