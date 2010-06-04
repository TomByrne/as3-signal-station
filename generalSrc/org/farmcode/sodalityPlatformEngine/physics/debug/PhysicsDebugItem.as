package org.farmcode.sodalityPlatformEngine.physics.debug
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityPlatformEngine.physics.advice.SetPhysicsDebugAreaAdvice;
	import org.farmcode.sodalityPlatformEngine.structs.items.SceneItem;

	public class PhysicsDebugItem extends SceneItem
	{
		public function PhysicsDebugItem(){
			super();
			isAdvisor = true;
			addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdded);
			var display:Sprite = new Sprite();
			display.mouseEnabled = false;
			_parallaxDisplay.display = display;
		}
		protected function onAdded(e:Event):void{
			var advice:SetPhysicsDebugAreaAdvice = new SetPhysicsDebugAreaAdvice(_parallaxDisplay.display as Sprite);
			dispatchEvent(advice);
		}
	}
}