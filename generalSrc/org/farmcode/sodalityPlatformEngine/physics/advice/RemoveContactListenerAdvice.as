package org.farmcode.sodalityPlatformEngine.physics.advice
{
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IRemoveContactListenerAdvice;

	public class RemoveContactListenerAdvice extends AbstractContactListenerAdvice implements IRemoveContactListenerAdvice
	{
		public function RemoveContactListenerAdvice(contactHandler:Function=null, contactBodies:Array=null){
			super(contactHandler,contactBodies);
		}
		
	}
}