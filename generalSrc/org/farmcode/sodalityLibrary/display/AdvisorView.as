package org.farmcode.sodalityLibrary.display
{
	import au.com.thefarmdigital.display.View;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodality.events.AdvisorEvent;
	
	import flash.events.Event;

	public class AdvisorView extends View implements IAdvisor
	{
		private var _addedToPresident: Boolean;
		private var _strictAdviceChecking: Boolean;
		private var _queueAdviceBeforeAdded: Boolean;
		private var pendingAdvice: Array;
		
		public function AdvisorView(queueAdviceBeforeAdded: Boolean = false,
			strictAdviceChecking: Boolean = true)
		{
			super();
			
			this.pendingAdvice = new Array();
			
			this.strictAdviceChecking = strictAdviceChecking;
			this._queueAdviceBeforeAdded = queueAdviceBeforeAdded;
			
			this._addedToPresident = false;
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, this.handleAdvisorAdded, false, int.MAX_VALUE);
			this.addEventListener(AdvisorEvent.ADVISOR_REMOVED, this.handleAdvisorRemoved, false, int.MIN_VALUE);
		}
		
		/*protected function set queueAdviceBeforeAdded(value: Boolean): void
		{
			this._queueAdviceBeforeAdded = value;
			// TODO: What should we do here if there is a pending queue?
			//  - throw an error?
			//	- make property only settable through constructor?
		}*/
		protected function get queueAdviceBeforeAdded(): Boolean
		{
			return this._queueAdviceBeforeAdded;
		}
		
		protected function set strictAdviceChecking(value: Boolean): void
		{
			this._strictAdviceChecking = value;
		}
		protected function get strictAdviceChecking(): Boolean
		{
			return this._strictAdviceChecking;
		}
		
		private function handleAdvisorAdded(event: AdvisorEvent): void
		{
			this._addedToPresident = true;
			if (this.queueAdviceBeforeAdded)
			{
				var afterAdvice: IAdvice = null;
				while (this.pendingAdvice.length > 0)
				{
					var advice: IAdvice = this.pendingAdvice.shift() as IAdvice;
					advice.executeAfter = afterAdvice;
					if (afterAdvice == null)
					{
						afterAdvice = advice;
					}
					this.dispatchEvent(advice as Event);
				}
			}
		}
		
		private function handleAdvisorRemoved(event: AdvisorEvent): void
		{
			this._addedToPresident = false;
		}
		
		protected function get addedToPresident(): Boolean
		{
			return this._addedToPresident;
		}
		
		override public function dispatchEvent(event:Event):Boolean
		{
			var result: Boolean = false;
			if (event is IAdvice && !this.addedToPresident)
			{
				if (this.queueAdviceBeforeAdded)
				{
					this.pendingAdvice.push(event);
					result = true;
				}
				else if (this.strictAdviceChecking)
				{
					throw new Error("Cannot dispatch advice from advisor; not yet added to president");
				}
			}
			else
			{
				result = super.dispatchEvent(event);
			}
			return result;			
		}
	}
}