package org.farmcode.sodalityPlatformEngine.behaviour
{
	import au.com.thefarmdigital.behaviour.BehaviourService;
	import au.com.thefarmdigital.behaviour.behaviours.IBehaviour;
	import au.com.thefarmdigital.behaviour.events.BehaviourServiceEvent;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodalityPlatformEngine.behaviour.adviceTypes.*;
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	public class BehaviourAdvisor extends DynamicAdvisor
	{
		override public function set advisorDisplay(value:DisplayObject):void{
			super.advisorDisplay = value;
			for each(var advisor:INonVisualAdvisor in advisorRules){
				advisor.advisorDisplay = value;
			}
		}
		
		protected var currentBehaviours:Dictionary;
		protected var abortedGoals:Dictionary;
		protected var advisorRules:Array;
		
		protected var behaviourService:BehaviourService;
		
		public function BehaviourAdvisor()
		{
			this.advisorRules = new Array();
			this.abortedGoals = new Dictionary();
			this.currentBehaviours = new Dictionary();
			
			this.behaviourService = new BehaviourService();
			this.behaviourService.addEventListener(BehaviourServiceEvent.BEHAVIOUR_EXECUTE, 
				this.handleBehaviourExecute);
			this.behaviourService.addEventListener(BehaviourServiceEvent.BEHAVIOUR_COMPLETE, 
				this.handleBehaviourComplete);
		}
		
		private function handleBehaviourExecute(event: BehaviourServiceEvent): void
		{
			for (var i: uint = 0; i < event.behaviours.length; ++i)
			{
				var beh: IBehaviour = event.behaviours[i];
				if (beh is INonVisualAdvisor)
				{
					var ad: INonVisualAdvisor = beh as INonVisualAdvisor;
					if (ad.advisorDisplay == null)
					{
						ad.advisorDisplay = this.advisorDisplay;
					}
				}
			}
		}
		private function handleBehaviourComplete(event: BehaviourServiceEvent): void
		{
			for (var i: uint = 0; i < event.behaviours.length; ++i)
			{
				var beh: IBehaviour = event.behaviours[i];
				if (beh is INonVisualAdvisor)
				{
					var ad: INonVisualAdvisor = beh as INonVisualAdvisor;
					if (ad.advisorDisplay == advisorDisplay)
					{
						ad.advisorDisplay = null;
					}
				}
			}
		}
		
		[Trigger(triggerTiming="after")]
		public function onAddGoal(cause:IAddGoalAdvice):void{
			if(cause.goal)behaviourService.addGoal(cause.goal);
		}
		[Trigger(triggerTiming="after")]
		public function onRemoveGoal(cause:IRemoveGoalAdvice):void{
			if(cause.goal)behaviourService.removeGoal(cause.goal);
		}
		[Trigger(triggerTiming="after")]
		public function onAddRule(cause:IAddBehaviourRuleAdvice):void{
			if(cause.rule){
				var cast:INonVisualAdvisor = cause.rule as INonVisualAdvisor;
				if(cast && !cast.advisorDisplay){
					advisorRules.push(cast);
					cast.advisorDisplay = this.advisorDisplay;
				}
				behaviourService.addRule(cause.rule);
			}
		}
		[Trigger(triggerTiming="after")]
		public function onRemoveRule( cause:IRemoveBehaviourRuleAdvice):void{
			if(cause.rule){
				behaviourService.removeRule(cause.rule);
				var index:Number = advisorRules.indexOf(cause.rule);
				if(index!=-1){
					var cast:INonVisualAdvisor = (cause.rule as INonVisualAdvisor);
					if(cast.advisorDisplay==this.advisorDisplay){
						cast.advisorDisplay = null;
					}
					advisorRules.splice(index,1);
				}
			}
		}
	}
}
