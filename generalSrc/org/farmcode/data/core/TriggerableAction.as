package org.farmcode.data.core
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	
	public class TriggerableAction implements ITriggerableAction
	{
		private var _dynamicAdvisor:DynamicAdvisor;
		
		public function TriggerableAction(){
		}
		
		public function triggerAction(scopeDisplay:DisplayObject):void{
			var advice:IAdvice = getAdvice();
			if(advice){
				if(!_dynamicAdvisor){
					_dynamicAdvisor = new DynamicAdvisor();
				}
				_dynamicAdvisor.advisorDisplay = scopeDisplay;
				_dynamicAdvisor.dispatchEvent(advice as Event);
				_dynamicAdvisor.advisorDisplay = null;
			}
		}
		protected function getAdvice():IAdvice{
			// override me
			return null;
		}
	}
}