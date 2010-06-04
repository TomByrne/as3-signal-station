package org.farmcode.sodalityPlatformEngine.physics.advice
{
	import flash.events.Event;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IAddContactListenerAdvice;
	import org.farmcode.sodality.advice.IAdvice;

	public class AddContactListenerAdvice extends AbstractContactListenerAdvice implements IAddContactListenerAdvice
	{
		public function AddContactListenerAdvice(contactHandler:Function=null, contactBodies:Array=null){
			super(contactHandler, contactBodies);
		}
		
	}
}