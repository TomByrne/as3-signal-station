package org.farmcode.sodalityPlatformEngine.physics.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IAddPhysicsSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	import org.farmcode.sodalityPlatformEngine.scene.advice.AddSceneItemAdvice;
	
	public class AddPhysicsSceneItemAdvice extends AddSceneItemAdvice 
		implements IAddPhysicsSceneItemAdvice
	{
		public function AddPhysicsSceneItemAdvice(sceneItemPath:String=null, 
			sceneItem:ISceneItem=null)
		{
			super(sceneItemPath, sceneItem);
		}
		
		override public function get revertAdvice() : Advice
		{
			return new RemovePhysicsSceneItemAdvice(this.sceneItemPath, this.sceneItem);
		}
	}
}