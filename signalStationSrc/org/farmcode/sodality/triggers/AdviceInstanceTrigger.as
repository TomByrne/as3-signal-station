package org.farmcode.sodality.triggers
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public class AdviceInstanceTrigger extends AbstractMemberAdviceTrigger
	{
		[Property(toString="true",clonable="true")]
		public var adviceInstance:IAdvice;
		
		public function AdviceInstanceTrigger(adviceInstance:IAdvice = null, advice:Array=null, timing:String=null){
			super(timing, advice);
			this.adviceInstance = adviceInstance;
		}
		
		
		override public function check(advice:IAdvice):Boolean{
			if(advice == adviceInstance && this.hasAdvice){
				this.addToManyAdvice(this.advice, advice);
			}
			return true;
		}
	}
}