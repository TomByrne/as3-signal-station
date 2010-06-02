package org.farmcode.sodalityLibrary.core.advice
{
	import flash.events.Event;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public class CascadingAdvice extends Advice implements IRevertableAdvice
	{
		protected var _linkedAdvice: Array;
		protected var currentExecutionIndex: int;
		private var _doRevert: Boolean;
		
		[Property(toString="true",clonable="true")]
		public var linkedRequired: Boolean;
		
		public function CascadingAdvice(abortable:Boolean=true, linkRequired: Boolean = false)
		{
			super(abortable);
			
			this._doRevert = true;
			this.linkedRequired = linkRequired;
			this.linkedAdvice = new Array();
			this.currentExecutionIndex = 0;
		}
		
		[Property(toString="true", clonable="true")]
		public function get doRevert(): Boolean
		{
			return this._doRevert;
		}
		public function set doRevert(value: Boolean): void
		{
			this._doRevert = value;
		}
		
		public function get revertAdvice(): Advice
		{
			var cAdvice: CascadingAdvice = new CascadingAdvice();
			for (var i: int = this.linkedAdvice.length - 1; i >= 0; i--)
			{
				var advice: IAdvice = this.linkedAdvice[i];
				if (advice is IRevertableAdvice)
				{
					var rAdvice: IRevertableAdvice = advice as IRevertableAdvice;
					if (rAdvice.doRevert)
					{
						cAdvice.addLinkedAdvice(rAdvice.revertAdvice);
					}
				}
			}
			return cAdvice;
		}
		
		[Property(toString="true",clonable="true")]
		public function set linkedAdvice(value: Array): void
		{
			this._linkedAdvice = value;
		}
		public function get linkedAdvice(): Array
		{
			return this._linkedAdvice;
		}
		
		public function addLinkedAdvice(advice: IAdvice): void
		{
			if (this.linkedAdvice.indexOf(advice) <= 0)
			{
				this.linkedAdvice.push(advice);
			}
		}
		
		public function removeLinkedAdvice(advice: IAdvice): void
		{
			var adviceIndex: int = this.linkedAdvice.indexOf(advice);
			if (adviceIndex >= 0)
			{
				this.linkedAdvice.splice(adviceIndex, 1);
			}
		}
		
		override protected function _execute(cause:IAdvice, time:String):void
		{
			if (this.linkedAdvice && this.linkedAdvice.length > 0)
			{
				this.executeNextLinked();
			}
			else if (this.linkedRequired)
			{
				throw new Error("Cannot execute Cascading Advice " + this + ", requires at least one linked advice");
			}
			else
			{
				super._execute(cause, time);
			}
		}
		
		protected function executeNextLinked(): void
		{
			if (this.currentExecutionIndex < this._linkedAdvice.length)
			{
				var nextLinked: IAdvice = this._linkedAdvice[this.currentExecutionIndex];
				nextLinked.addEventListener(Event.COMPLETE, this.handleLinkedCompleteEvent, 
					false, 0, true);
				//nextLinked.executeBefore = this;
				this.executeLinkedAdvice(nextLinked);
			}
			else
			{
				this.linkedAdviceComplete();
			}
		}
		
		protected function executeLinkedAdvice(advice: IAdvice): void
		{
			this.dispatchEvent(advice as Event);
		}
		
		protected function handleLinkedCompleteEvent(event: Event): void
		{
			var targetAdvice: IAdvice = event.target as IAdvice;
			targetAdvice.removeEventListener(Event.COMPLETE, this.handleLinkedCompleteEvent);
			_linkedAdvice[currentExecutionIndex] = targetAdvice;
			this.currentExecutionIndex++;
			this.executeNextLinked();
		}
		
		protected function linkedAdviceComplete(): void
		{
			this.adviceContinue();
		}
	}
}