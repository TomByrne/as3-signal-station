package org.farmcode.acting.universal.rules
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.reactions.IActReaction;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	public class ImmediateActRule implements IUniversalRule
	{
		
		public function get act():IUniversalAct{
			return _act;
		}
		public function set act(value:IUniversalAct):void{
			_act = value;
		}
		
		private var _act:IUniversalAct;
		
		public function ImmediateActRule(act:IUniversalAct=null){
			this.act = act;
		}
		public function shouldReact(act:IUniversalAct):Boolean{
			return (act==_act);
		}
		public function shouldReactBefore(act:IUniversalAct, reaction:IActReaction):Boolean{
			return true;
		}
		public function shouldReactAfter(act:IUniversalAct, reaction:IActReaction):Boolean{
			return false;
		}
	}
}