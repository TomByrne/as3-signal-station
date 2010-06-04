package org.farmcode.sodalityLibrary.memory
{
	import au.com.thefarmdigital.memory.ObjectDisposeTracker;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public class ObjectDisposeTrackerAdvisor extends ObjectDisposeTracker implements INonVisualAdvisor
	{
		private var advisor: DynamicAdvisor;
		private var activeAdvice: Array;
		
		public function ObjectDisposeTrackerAdvisor()
		{
			super();
			
			this.advisor = new DynamicAdvisor(null, this);
			this.activeAdvice = new Array();
		}
		
		public function dispatchAndAddAdvice(advice: IRevertableAdvice): void
		{
			this.addActiveAdvice(advice);
			this.dispatchEvent(advice as Event);
		}
		
		public function addActiveAdvice(advice: IRevertableAdvice): void
		{
			if (this.activeAdvice.indexOf(advice) < 0)
			{
				this.activeAdvice.push(advice);
			}
		}
		
		public function removeActiveAdvice(advice: IRevertableAdvice): void
		{
			var adviceIndex: int = this.activeAdvice.indexOf(advice);
			if (adviceIndex >= 0)
			{
				this.activeAdvice.splice(adviceIndex, 1);
			}
		}
		
		public function revertActiveAdvice(before: IAdvice = null, after: IAdvice = null): void
		{
			while (this.activeAdvice.length > 0)
			{
				var advice: IRevertableAdvice = this.activeAdvice.pop() as IRevertableAdvice;
				if (advice.doRevert)
				{
					var rAdvice: Advice = advice.revertAdvice;
					rAdvice.executeBefore = before;
					rAdvice.executeAfter = after;
					this.dispatchEvent(rAdvice);
				}
			}
		}
		
		public function revertSingleActiveAdvice(advice: IRevertableAdvice, before: IAdvice = null,
			after: IAdvice = null): void
		{
			var adviceIndex: int = this.activeAdvice.indexOf(advice);
			if (adviceIndex >= 0)
			{
				var advice: IRevertableAdvice = this.activeAdvice[adviceIndex];
				advice.executeBefore = before;
				advice.executeAfter = after;
				this.dispatchEvent(advice.revertAdvice);
				this.activeAdvice.splice(adviceIndex, 1);
			}
		}
		
		public function set advisorDisplay(value:DisplayObject):void
		{
			this.advisor.advisorDisplay = value;
		}
		public function get advisorDisplay():DisplayObject
		{
			return this.advisor.advisorDisplay;
		}
		
		public function set addedToPresident(value:Boolean):void
		{
			this.advisor.addedToPresident = value;
		}
		public function get addedToPresident():Boolean
		{
			return this.advisor.addedToPresident;
		}
		
		public function sodalityDispose(before: IAdvice = null, after: IAdvice = null):void
		{
			super.dispose();
			this.revertActiveAdvice(before, after);
		}
		
		override public function dispatchEvent(event:Event):Boolean
		{
			var result: Boolean = false;
			if (event is IAdvice && (this.advisorDisplay == null || this.advisorDisplay.stage == null))
			{
				throw new Error("Trying to dispatch advice when not connected to stage");
			}
			else
			{
				result = super.dispatchEvent(event);
			}
			return result;
		}
	}
}