package org.tbyrne.acting.universal.rules
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.reactions.IActReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	
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
		public function sortAgainst(act:IUniversalAct, reaction:IActReaction):int{
			var ret:int = 0;
			if(reaction.phases){
				var reactionPhases:Array = reaction.phases;
				var phase:String;
				if(beforePhases){
					for each(phase in beforePhases){
						if(reactionPhases.indexOf(phase)!=-1){
							ret = -1;
						}
					}
				}
				if(afterPhases){
					for each(phase in afterPhases){
						if(reactionPhases.indexOf(phase)!=-1){
							if(ret!=0){
								Log.error("There is a conflict in before and after phases: "+beforePhases+" "+afterPhases);
							}
							ret = 1;
						}
					}
				}
			}
			return ret;
		}
	}
}