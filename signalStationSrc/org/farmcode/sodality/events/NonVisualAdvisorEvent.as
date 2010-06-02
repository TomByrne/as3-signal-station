package org.farmcode.sodality.events
{
	import org.farmcode.sodality.advisors.IAdvisor;

	public class NonVisualAdvisorEvent extends AdvisorEvent
	{
		public static const ADVISOR_ADD_REQUEST:String = "advisorAddRequest";
		public static const ADVISOR_REMOVE_REQUEST:String = "advisorRemoveRequest";
		
		public function NonVisualAdvisorEvent(advisor:IAdvisor, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(advisor, type, bubbles, cancelable);
		}
		
	}
}