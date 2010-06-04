package org.farmcode.sodalityPlatformEngine.physics.advice
{
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IRemovePhysicsSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	import org.farmcode.sodalityPlatformEngine.scene.advice.RemoveSceneItemAdvice;
	
	public class RemovePhysicsSceneItemAdvice extends RemoveSceneItemAdvice implements IRemovePhysicsSceneItemAdvice
	{
		public function RemovePhysicsSceneItemAdvice(sceneItemPath:String=null, 
			sceneItem:ISceneItem=null)
		{
			super(sceneItemPath, sceneItem);
		}
	}
}