package org.tbyrne.acting.universal
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.reactions.IActReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	import org.tbyrne.utils.methodClosure;

	public class UniversalReactionSorter
	{
		protected function sortReactions(act:IUniversalAct, reactors:Array, rules:Dictionary):Array{
			if(reactors.length){
				return reactors.sort(methodClosure(doSortReactions,act,rules));
				/*var newList:Array = [reactors[0]];
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
								Log.error( "UniversalReactionSorter.sortReactors: This list of IActReactions can not be ordered");
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
								Log.error( "UniversalReactionSorter.sortReactors: IActReaction has a conflicting position in list");
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
				return newList;*/
			}
			return reactors;
		}
		private function doSortReactions(reaction1:IActReaction, reaction2:IActReaction, act:IUniversalAct, rules:Dictionary):int{
			var rule1:IUniversalRule = rules[reaction1];
			var rule2:IUniversalRule = rules[reaction2];
			
			var sort1:int = rule1.sortAgainst(act,reaction2);
			var sort2:int = rule2.sortAgainst(act,reaction1);
			
			if(sort1==0){
				if(sort2==-1){
					sort1 = 1;
				}else if(sort2==1){
					sort1 = -1;
				}
			}
			return sort1;
		}
		/*private function shouldReactBefore(act:IUniversalAct, reaction1:IActReaction, reaction2:IActReaction, rule1:IUniversalRule, rule2:IUniversalRule):Boolean{
			var sort1:int = rule1.sortAgainst(act,reaction2);
			var sort2:int = rule2.sortAgainst(act,reaction1);
			
			if(sort1!=0){
				if(sort1==sort2)Log.error( "UniversalReactionSorter.shouldReactBefore: IActReactions with conflicting sorting");
			}else if(sort2==0){
				Log.error( "UniversalReactionSorter.shouldReactBefore: IActReactions don't specify sprting");
			}
			return (sort1==-1 || sort2==1);
		}*/
		protected function copyDictionary(dictionary:Dictionary):Dictionary{
			var ret:Dictionary = new Dictionary();
			for(var i:* in dictionary){
				ret[i] = dictionary[i];
			}
			return ret;
		}
	}
}