package org.farmcode.sodalityPlatformEngine.behaviour.advice
{
	import au.com.thefarmdigital.behaviour.IBehavingItem;
	import au.com.thefarmdigital.behaviour.rules.IBehaviourRule;
	import au.com.thefarmdigital.behaviour.rules.ISingleItemRule;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.behaviour.adviceTypes.IRemoveBehaviourRuleAdvice;

	public class RemoveBehaviourRuleAdvice extends AbstractBehaviourAdvice implements IRemoveBehaviourRuleAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get rule():IBehaviourRule{
			return _rule;
		}
		public function set rule(value:IBehaviourRule):void{
			_rule = value;
		}
		/*public function get rulePath():String{
			return _rulePath;
		}*/
		public function set rulePath(value:String):void{
			_rulePath = value;
		}
		
		private var _rulePath:String;
		private var _rule:IBehaviourRule;
		
		public function RemoveBehaviourRuleAdvice(rulePath:String=null, rule:IBehaviourRule=null, behavingItemPath:String=null, behavingItem:IBehavingItem=null){
			super(behavingItemPath, behavingItem);
			this.rulePath = rulePath;
			this.rule = rule;
		}
		override public function get resolvePaths():Array{ 
			var ret:Array = super.resolvePaths;
			if(!rule && _rulePath)ret.push(_rulePath);
			return ret;
		}
		override public function set resolvedObjects(value:Dictionary):void{
			super.resolvedObjects = value;
			var rule:IBehaviourRule = value[_rulePath];
			if(rule)this.rule = rule;
		}
		override protected function _execute(cause:IAdvice, time:String):void{
			if(rule && behavingItem && rule is ISingleItemRule){
				(rule as ISingleItemRule).behavingItem = behavingItem;
			}
			adviceContinue();
		}
		
		public function get doRevert(): Boolean{
			return true;
		}
		
		public function get revertAdvice(): Advice{
			return new AddBehaviourRuleAdvice(_rulePath, this.rule, _behavingItemPath, this.behavingItem);
		}
	}
}