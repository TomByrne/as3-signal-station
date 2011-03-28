package org.tbyrne.acting.universal.rules
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.metadata.ruleTypes.IUniversalClassRule;
	import org.tbyrne.acting.universal.reactions.IActReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	
	public class CompositeActRule implements IUniversalRule
	{
		public function get rules():Vector.<IUniversalRule>{
			return _rules;
		}
		public function set rules(value:Vector.<IUniversalRule>):void{
			if(_rules!=value){
				//if(_rules)setActClass(null);
				_rules = value;
				//if(_rules)setActClass(_actClass);
			}
		}
		
		private var _rules:Vector.<IUniversalRule>;
		//private var _actClass:Class;
		
		
		public function CompositeActRule(rules:Vector.<IUniversalRule>=null){
			this.rules = rules;
		}
		
		/*public function set actClass(value:Class):void{
			if(_actClass!=value){
				_actClass = value;
				if(_rules)setActClass(_actClass);
			}
		}
		
		private function setActClass(value:Class):void{
			for each(var rule:IUniversalRule in _rules){
				var classRule:IUniversalClassRule = (rule as IUniversalClassRule);
				if(classRule){
					classRule.actClass = value;
				}
			}

		}*/
		
		
		public function shouldReact(act:IUniversalAct):Boolean{
			if(_rules && _rules.length){
				var react:Boolean = true;
				for each(var rule:IUniversalRule in _rules){
					if(!rule.shouldReact(act)){
						react = false;
						break;
					}
				}
				return react;
			}
			return false;
		}
		
		public function sortAgainst(act:IUniversalAct, reaction:IActReaction):int{
			if(_rules && _rules.length){
				var ret:int = 0;
				for each(var rule:IUniversalRule in _rules){
					var ruleSort:int = rule.sortAgainst(act,reaction)
					if(ruleSort!=0 && ruleSort!=ret){
						if(ret!=0){
							Log.error("Sorting conflict exists in CompositeActRule");
						}else{
							ret = ruleSort;
						}
					}
				}
				return ret;
			}
			return 0;
		}
	}
}