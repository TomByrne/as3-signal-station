package org.farmcode.acting.universal.rules.abstract
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public class BaseActInstanceRule extends BaseActRule
	{
		public function get act():IUniversalAct{
			return _act;
		}
		public function set act(value:IUniversalAct):void{
			_act = value;
		}
		
		private var _act:IUniversalAct;
		
		public function BaseActInstanceRule(executeBefore:Boolean, act:IUniversalAct=null){
			super(executeBefore);
			this.act = act;
		}
		override public function shouldExecute(act:IUniversalAct):Boolean{
			return _act==act;
		}
	}
}