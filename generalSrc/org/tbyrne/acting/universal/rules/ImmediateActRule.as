package org.tbyrne.acting.universal.rules
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.reactions.IActReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	
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
		public function sortAgainst(act:IUniversalAct, reaction:IActReaction):int{
			return -1;
		}
	}
}