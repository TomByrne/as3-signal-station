package org.farmcode.acting.universal.rules.abstract
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	public class BaseActRule implements IUniversalRule
	{
		public function get subRules():Array{
			return _subRules;
		}
		public function set subRules(value:Array):void{
			_subRules = value;
		}
		
		protected var _subRules:Array;
		protected var _executeBefore:Boolean;
		
		public function BaseActRule(executeBefore:Boolean){
			_executeBefore = executeBefore;
		}
		
		public function shouldExecute(act:IUniversalAct):Boolean{
			return false;
		}
		public function shouldExecuteBefore(act:IUniversalAct, beforeInstigator:Boolean, afterInstigator:Boolean):Boolean{
			if(_subRules && (beforeInstigator || afterInstigator)){
				// this is not the instigator, test it against sub-rules.
				for(var i:* in _subRules){
					var rule:IUniversalRule = (i as IUniversalRule);
					if(rule.shouldExecute(act)){
						return rule.shouldExecuteBefore(act,beforeInstigator,afterInstigator);
					}
				}
			}
			return _executeBefore;
		}
		public function addSubRule(rule:IUniversalRule):void{
			if(_subRules.indexOf(rule)==-1){
				_subRules.push(rule);
			}
		}
		public function removeSubRule(rule:IUniversalRule):void{
			var index:int = _subRules.indexOf(rule);
			if(index!=-1){
				_subRules.splice(index,1);
			}
		}
	}
}