package org.farmcode.sodality.advisors
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodality.events.DynamicAdvisorEvent;
	import org.farmcode.sodality.events.NonVisualAdvisorEvent;
	import org.farmcode.sodality.triggers.IAdviceTrigger;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(type="org.farmcode.sodality.events.AdvisorEvent",name="advisorAdded")]
	[Event(type="org.farmcode.sodality.events.AdvisorEvent",name="advisorRemoved")]
	[Event(name="triggersChanged",type="org.farmcode.sodality.events.DynamicAdvisorEvent")]
	/**
	 * The DynamicAdvisor class implements both the IDynamicAdvisor and the INonVisualAdvisor interfaces,
	 * making this the perfect base class for the majority of non-visual advisors.
	 */
	public class DynamicAdvisor extends EventDispatcher implements IDynamicAdvisor, INonVisualAdvisor
	{
		private static const HIGH_PRIORITY: int = int.MAX_VALUE - 1000;
		
		protected var _triggers:Array = [];
		protected var _advisorDisplay:DisplayObject;
		protected var _addedToPresident:Boolean;

		public function get triggers():Array{
			return _triggers;
		}
		public function set triggers(value:Array):void{
			if(_triggers!=value){
				_triggers = value;
				dispatchEvent(new DynamicAdvisorEvent(DynamicAdvisorEvent.TRIGGERS_CHANGED));
			}
		}
		public function get advisorDisplay():DisplayObject{
			return _advisorDisplay;
		}
		public function set advisorDisplay(value:DisplayObject):void{
			if(_advisorDisplay!=value){
				if(_advisorDisplay){
					if(_advisorDisplay.stage)onRemovedFromStage(null);
					_advisorDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					_advisorDisplay.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
				}
				_advisorDisplay=value;
				if(_advisorDisplay){
					_advisorDisplay.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, DynamicAdvisor.HIGH_PRIORITY);
					_advisorDisplay.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, DynamicAdvisor.HIGH_PRIORITY);
					if(_advisorDisplay.stage)onAddedToStage();
				}
			}
		}
		public function get addedToPresident():Boolean{
			return _addedToPresident;
		}
		public function set addedToPresident(value:Boolean):void{
			_addedToPresident = value;
		}
		
		protected var _target: IAdvisor;
		public function get target(): IAdvisor
		{
			return this._target;
		}
		
		public function DynamicAdvisor(advisorDisplay:DisplayObject=null, target: IAdvisor = null){
			if (target == null)
			{
				target = this;
			}
			this._target = target;
			if (advisorDisplay != null)
			{
				this.advisorDisplay = advisorDisplay;
			}
		}
		protected function onAddedToStage(e:Event=null):void{
			_advisorDisplay.dispatchEvent(new NonVisualAdvisorEvent(this.target,NonVisualAdvisorEvent.ADVISOR_ADD_REQUEST,true));
		}
		protected function onRemovedFromStage(e:Event=null):void{
			_advisorDisplay.dispatchEvent(new NonVisualAdvisorEvent(this.target,NonVisualAdvisorEvent.ADVISOR_REMOVE_REQUEST,true));
		}
		
		public function addTrigger(trigger:IAdviceTrigger):void{
			_triggers.push(trigger);
			target.dispatchEvent(new DynamicAdvisorEvent(DynamicAdvisorEvent.TRIGGERS_CHANGED));
		}
		
		public function removeTrigger(trigger:IAdviceTrigger):void{
			var index:int = _triggers.indexOf(trigger);
			if (index >= 0)
			{
				_triggers.splice(index,1);
				dispatchEvent(new DynamicAdvisorEvent(DynamicAdvisorEvent.TRIGGERS_CHANGED));
			}
			else
			{
				throw new Error("Cannot remove a trigger which isn't managed");
			}
		}
		
		public function hasTrigger(trigger: IAdviceTrigger): Boolean
		{
			return this.triggers.indexOf(trigger) >= 0;
		}
		
		protected function removeFromPresident(): void
		{
			this.dispatchEvent(new AdvisorEvent(this.target, AdvisorEvent.ADVISOR_REMOVED));
		}
		
		/*override public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}*/
		override public function dispatchEvent(event:Event):Boolean
		{
			if (event is IAdvice && !this.addedToPresident)
			{
				if (this.advisorDisplay == null)
				{
					trace("WARNING: Attempting to dispatch advice " + event + " with no advisorDisplay");
				}
				else if (this.advisorDisplay.stage == null)
				{
					trace("WARNING: Attempting to dispatch advice " + event + " with advisorDisplay not on stage");
				}
				else
				{
					trace("WARNING: Cannot dispatch advice from advisor; not yet added to president");
				}
			}
			if (this.target == this)
			{
				return super.dispatchEvent(event); 
			}
			else
			{
				return this.target.dispatchEvent(event);
			}			
		}
	}
}