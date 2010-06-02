package org.farmcode.sodality.advice
{
	
	public class SetPropertyAdvice extends AbstractMemberAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get value():*{
			return _value;
		}
		public function set value(value:*):void{
			_value = value;
		}
		
		private var _value:*;
		
		public function SetPropertyAdvice(subject:Object=null, memberName:String=null, value:*=null, abortable:Boolean=true){
			super(subject, memberName, null, abortable);
			this.value = value;
		}
		override protected function _execute(cause:IAdvice, time:String):void{
			subject[memberName] = value;
			adviceContinue();
		}
		
	}
}