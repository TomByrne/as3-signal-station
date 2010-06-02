package org.farmcode.sodality.triggers
{
	import flash.utils.getQualifiedClassName;
	
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.sodality.advice.IAdvice;

	public class AdviceClassTrigger extends AbstractMemberAdviceTrigger implements IAdviceClassTrigger
	{
		[Property(toString="true",clonable="true")]
		public var adviceClass:Class;
		
		public function AdviceClassTrigger(adviceClass:Class = null, advice:Array=null, timing:String=null){
			super(timing, advice);
			this.adviceClass = adviceClass;
		}
		
		public function set adviceClassName(adviceClassName: String): void
		{
			try
			{
				this.adviceClass = ReflectionUtils.getClassByName(adviceClassName);
			}
			catch (e: ReferenceError)
			{
				throw new ReferenceError("In AdviceClassTrigger: " + e.message);
			}
		}
		public function get adviceClassName(): String
		{
			return getQualifiedClassName(this.adviceClass);
		}
		
		override public function check(advice:IAdvice):Boolean{
			if(advice is adviceClass && this.hasAdvice)
			{
				this.addToManyAdvice(this.advice, advice);
			}
			return true;
		}
	}
}