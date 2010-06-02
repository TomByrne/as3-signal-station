package org.farmcode.acting.universal.rules
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.reactions.IActReaction;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	public class PhasedActRule implements IUniversalRule
	{
		public var afterPhases:Array;
		public var beforePhases:Array;
		
		public function PhasedActRule(beforePhases:Array=null, afterPhases:Array=null){
			this.beforePhases = beforePhases;
			this.afterPhases = afterPhases;
		}
		
		public function shouldReact(act:IUniversalAct):Boolean{
			return false;
		}
		public function shouldReactBefore(act:IUniversalAct, reaction:IActReaction):Boolean{
			if(beforePhases && reaction.phases){
				var reactionPhases:Array = reaction.phases;
				for each(var phase:String in beforePhases){
					if(reactionPhases.indexOf(phase)!=-1){
						return true;
					}
				}
			}
			return false;
		}
		public function shouldReactAfter(act:IUniversalAct, reaction:IActReaction):Boolean{
			if(afterPhases && reaction.phases){
				var reactionPhases:Array = reaction.phases;
				for each(var phase:String in afterPhases){
					if(reactionPhases.indexOf(phase)!=-1){
						return true;
					}
				}
			}
			return false;
		}
	}
}