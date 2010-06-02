package org.farmcode.sodality.triggerResponseCache
{
	import flash.utils.Dictionary;
	
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.triggers.AdviceClassTrigger;
	import org.farmcode.sodality.triggers.IAdviceTrigger;

	// TODO: Use a parallel dictionary for triggers as it may provide quicker presence checks?
	// Find a way to remove bundle objects? seems to add searching overhead
	public class AdviceClassTriggerResponseCache implements ITriggerResponseCache
	{
		protected var triggers:Array;
		protected var cachedResponse:Dictionary;
		
		public function AdviceClassTriggerResponseCache()
		{
			this.triggers = new Array();
			this.cachedResponse = new Dictionary();
		}
		
		private function getBundleIndexForTrigger(trigger: IAdviceTrigger): int
		{
			var index: int = -1;
			for (var i: uint = 0; i < this.triggers.length && index < 0; ++i)
			{
				var testBundle: TriggerBundle = this.triggers[i];
				if (testBundle.trigger == trigger)
				{
					index = i;
				}
			}
			return index;
		}
		
		private function getBundleForTrigger(trigger: IAdviceTrigger): TriggerBundle
		{
			var bundle: TriggerBundle = null;
			var index: int = this.getBundleIndexForTrigger(trigger);
			if (index >= 0)
			{
				bundle = this.triggers[index];
			}
			return bundle;
		}
		
		public function addTrigger(trigger:IAdviceTrigger):void{
			var triggerBundle: TriggerBundle = this.getBundleForTrigger(trigger);
			if(!triggerBundle){
				triggerBundle = new TriggerBundle(trigger);
				this.triggers.push(triggerBundle);
				
				for each(var bundle:AdviceClassBundle in cachedResponse){
					if(this.matchByClass(bundle.adviceClass,trigger)){
						triggerBundle.adviceClasses.push(bundle);
						bundle.addTrigger(trigger);
					}
				}
			}
		}
		public function removeTrigger(trigger:IAdviceTrigger):void{
			var bundleIndex: int = this.getBundleIndexForTrigger(trigger);
			if (bundleIndex >= 0)
			{
				var triggerBundle: TriggerBundle = this.triggers[bundleIndex];
			
				for each(var bundle:AdviceClassBundle in triggerBundle.adviceClasses){
					bundle.removeTrigger(trigger);
				}
				this.triggers.splice(bundleIndex, 1);
			}
			else
			{
				throw new Error("Cannot remove non tracked trigger");				
			}
		}
		public function getTriggers(advice:IAdvice):Array{
			var klass:Class = ReflectionUtils.getClass(advice);
			var bundle:AdviceClassBundle = cachedResponse[klass];
			
			if(!bundle) {
				
				bundle = new AdviceClassBundle(ReflectionUtils.getClass(advice));
				cachedResponse[klass] = bundle;
				for (var i: uint = 0; i < this.triggers.length; ++i){
					var triggerBundle: TriggerBundle = this.triggers[i];
					if(match(advice, triggerBundle.trigger)){
						triggerBundle.adviceClasses.push(bundle);
						bundle.addTrigger(triggerBundle.trigger);
					}
				}
			}
			return bundle.triggers;
		}
		protected function match(advice:IAdvice, trigger:IAdviceTrigger):Boolean{
			if(trigger is AdviceClassTrigger){
				var cast:AdviceClassTrigger = trigger as AdviceClassTrigger;
				return (advice is cast.adviceClass);
			}else{
				return true;
			}
		}
		
		protected function matchByClass(adviceClass: Class, trigger: IAdviceTrigger): Boolean
		{
			if(trigger is AdviceClassTrigger){
				var cast:AdviceClassTrigger = trigger as AdviceClassTrigger;
				return ReflectionUtils.isClassInstanceOf(adviceClass, cast.adviceClass);
			}else{
				return true;
			}
		}
	}
}

import org.farmcode.sodality.advice.IAdvice;
import org.farmcode.sodality.triggers.IAdviceTrigger;
	
class AdviceClassBundle
{
	public var adviceClass: Class;
	private var _triggers:Array;
	
	public function AdviceClassBundle(adviceClass: Class)
	{
		this.adviceClass = adviceClass;
		this._triggers = new Array();
	}
	
	public function get triggers(): Array
	{
		return this._triggers;
	}
	
	public function addTrigger(trigger: IAdviceTrigger): void
	{
		this._triggers.push(trigger);
	}
	
	public function removeTrigger(trigger: IAdviceTrigger): void
	{
		var index: int = this._triggers.indexOf(trigger);
		if (index >= 0)
		{
			this._triggers.splice(index, 1);
		}
	}
}

class TriggerBundle
{
	public var adviceClasses: Array;
	public var trigger: IAdviceTrigger;
	
	public function TriggerBundle(trigger: IAdviceTrigger)
	{
		this.adviceClasses = new Array();
		this.trigger = trigger;
	}
}