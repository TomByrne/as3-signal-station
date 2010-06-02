package org.farmcode.sodalityLibrary.core.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;

	public class ContinueOnExecuteAdvice extends Advice
	{
		private var _targetAdvice: Advice;
		
		public function ContinueOnExecuteAdvice(targetAdvice: Advice = null, abortable:Boolean=true)
		{
			super(abortable);
			
			this.targetAdvice = targetAdvice;
		}
		
		[Property(clonable="true")]
		public function set targetAdvice(value: Advice): void
		{
			this._targetAdvice = value;
		}
		public function get targetAdvice(): Advice
		{
			return this._targetAdvice;
		}
		
		override protected function _execute(cause:IAdvice, time:String):void
		{
			this.targetAdvice.adviceContinue();
			
			super._execute(cause, time);
		}
	}
}