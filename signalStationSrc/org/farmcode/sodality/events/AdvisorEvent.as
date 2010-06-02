package org.farmcode.sodality.events
{
	import org.farmcode.sodality.advisors.IAdvisor;
	
	import flash.events.Event;

	/**
	 * The AdvisorEvent class can be utilised to add/remove non-visual advisors from the President.
	 * To use it, dispatch either the ADVISOR_ADDED or ADVISOR_REMOVED events from any displayObject
	 * (which is a decendant of the President's headAdvisor).<br>
	 * NOTE: Make sure you set bubbling to true.
	 */
	public class AdvisorEvent extends Event
	{
		// Types
		public static const ADVISOR_ADDED:String = "advisorAdded";
		public static const ADVISOR_REMOVED:String = "advisorRemoved";
		
		public var advisor:IAdvisor;
		
		public function AdvisorEvent(advisor:IAdvisor, type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
			this.advisor = advisor;
		}
		override public function clone():Event{
			return new AdvisorEvent(advisor,type,bubbles,cancelable);
		}
	}
}