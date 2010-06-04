package org.farmcode.acting.universal.rules
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	import org.farmcode.acting.universal.rules.abstract.BaseActClassRule;
	import org.farmcode.acting.universal.rules.abstract.BaseActRule;
	
	public class ImmediateAfterAct extends BaseActClassRule
	{
		public function ImmediateAfterAct(){
			super(false);
		}
		override public function shouldExecuteBefore(act:IUniversalAct, beforeInstigator:Boolean, afterInstigator:Boolean):Boolean{
			if(_subRules && (beforeInstigator || afterInstigator)){
				// this is not the instigator, test it against sub-rules.
				for(var i:* in _subRules){
					var rule:IUniversalRule = (i as IUniversalRule);
					if(rule.shouldExecute(act)){
						return rule.shouldExecuteBefore(act,beforeInstigator,afterInstigator);
					}
				}
			}
			return afterInstigator;
		}
	}
}