package org.farmcode.sodality.triggers
{
	import org.farmcode.sodality.advice.IAdvice;

	public class AbstractMemberAdviceTrigger extends AbstractAdviceTrigger implements IMemberAdviceTrigger
	{
		[Property(toString="true",clonable="true")]
		public function get advice(): Array
		{
			return _advice;
		}
		public function set advice(value:Array):void
		{
			_advice = value;
		}
		
		private var _advice:Array;
		
		public function AbstractMemberAdviceTrigger(triggerTiming:String=null, advice:Array=null){
			super(triggerTiming);
			_advice = advice;
		}
		
		public function get hasAdvice(): Boolean
		{
			return this.advice != null && this.advice.length > 0;
		}
	}
}