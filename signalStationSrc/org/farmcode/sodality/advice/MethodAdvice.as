package org.farmcode.sodality.advice
{
	/**
	 * MethodAdvice is the default advice attached to methods which have [Advice] metadata
	 * prepending them. MethodAdvice simply calls a method with the supplied arguments.<br>
	 * Here is an example of using Sodality metadata to add MethodAdvice:<br>
	 * <code>
	 * [Trigger(...)]
	 * [Advice(12,"hello","[0,1,2,3]")]
	 * public function myFunction(arg1:Number, arg2:String, arg3:Array):void{
	 * 	trace("Advice with the type 'allMyAdvice/mySpecificAdvice' was dispatched elsewhere in the application.");
	 * }
	 * </code>
	 */
	public class MethodAdvice extends AbstractMemberAdvice
	{
		public function MethodAdvice(subject:Object=null, methodName:String=null, arguments:Array = null, abortable:Boolean=true){
			super(subject, methodName, arguments, abortable);
			
		}
		override protected function _execute(cause:IAdvice, time:String):void{
			var func:Function = subject[memberName];
			if(func!=null){
				var args:Array = this.arguments?[cause].concat(this.arguments):[cause];
				func.apply(null,args);
			}else{
				throw new Error(subject+" doesn't have the method "+memberName);
			}
			adviceContinue();
		}
	}
}