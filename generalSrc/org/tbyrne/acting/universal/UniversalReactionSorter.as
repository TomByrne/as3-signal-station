package org.tbyrne.acting.universal
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.reactions.IActReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;

	public class UniversalReactionSorter
	{
		protected function sortReactors(act:IUniversalAct, reactors:Array, rules:Dictionary):Array{
			if(reactors.length){
				var newList:Array = [reactors[0]];
				var newListCount:int = 1;
				var takenList:Array = [0];
				var index:int = 0;
				var taken:Boolean = false;
				
				while(takenList.length<reactors.length){
					var search:Boolean = false;
					while(takenList.indexOf(index)!=-1 || !search){
						search = true;
						++index;
						if(index==reactors.length){
							if(!taken){
								throw new Error("This list of IActReactions can not be ordered");
							}
							index = 0;
							taken = false;
						}
					}
					var reaction1:IActReaction = reactors[index];
					var rule1:IUniversalRule = rules[reaction1];
					
					var minIndex:int = -1;
					var maxIndex:int = -1;
					for(var i:int=0; i<newListCount; i++){
						var reaction2:IActReaction = newList[i];
						var rule2:IUniversalRule = rules[reaction2];
						
						if(maxIndex==-1 && shouldReactBefore(act,reaction1,reaction2,rule1,rule2)){
							maxIndex = i;
						}
						if(shouldReactBefore(act,reaction2,reaction1,rule2,rule1)){
							if(maxIndex==-1 || maxIndex==i){
								minIndex = i+1;
							}else{
								throw new Error("IActReaction has a conflicting position in list.");
							}
						}
					}
					var particleIndex:int = (maxIndex!=-1?maxIndex:minIndex);
					if(particleIndex!=-1){
						taken = true;
						newList.splice(particleIndex,0,reaction1);
						takenList.push(index);
						++newListCount;
					}
				}
				return newList;
			}
			return reactors;
		}
		private function shouldReactBefore(act:IUniversalAct, reaction1:IActReaction, reaction2:IActReaction, rule1:IUniversalRule, rule2:IUniversalRule):Boolean{
			if(rule1.shouldReactBefore(act,reaction2)){
				return true;
			}
			if(rule2.shouldReactAfter(act,reaction1)){
				return true;
			}
			return false;
		}
		protected function copyDictionary(dictionary:Dictionary):Dictionary{
			var ret:Dictionary = new Dictionary();
			for(var i:* in dictionary){
				ret[i] = dictionary[i];
			}
			return ret;
		}
	}
}