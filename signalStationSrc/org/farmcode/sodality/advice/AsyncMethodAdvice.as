package org.farmcode.sodality.advice
{
	public class AsyncMethodAdvice extends AbstractMemberAdvice
	{
		public function AsyncMethodAdvice(subject:Object=null, methodName:String=null, 
			arguments:Array = null, abortable:Boolean=true) {
			super(subject, methodName, arguments, abortable);
		}
		override protected function _execute(cause:IAdvice, time:String):void{
			var func:Function = subject[memberName];
			if(func!=null){
				var args:Array = [cause,this,time]
				if(this.arguments)args = args.concat(this.arguments);
				func.apply(null,args);
			}else{
				throw new Error(subject+" doesn't have the method "+memberName);
			}
		}
	}
}