package org.farmcode.acting.universal.rules.abstract
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.metadata.ruleTypes.IUniversalClassRule;
	
	public class BaseActClassRule extends BaseActRule implements IUniversalClassRule
	{
		
		public function get actClass():Class{
			return _actClass;
		}
		public function set actClass(value:Class):void{
			_actClass = value;
		}
		
		private var _actClass:Class;
		
		public function BaseActClassRule(executeBefore:Boolean, actClass:Class=null){
			super(executeBefore);
			this.actClass = actClass;
		}
		override public function shouldExecute(act:IUniversalAct):Boolean{
			return act is _actClass;
		}
	}
}