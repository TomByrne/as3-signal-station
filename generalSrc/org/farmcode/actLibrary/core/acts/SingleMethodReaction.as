package org.farmcode.actLibrary.core.acts
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	public class SingleMethodReaction extends MethodReaction
	{
		private var singleUseRule:IUniversalRule;
		
		public function SingleMethodReaction(scopeDisplay:DisplayObject=null, asyncHandler:Function=null, rule:IUniversalRule=null, doAsynchronous:Boolean=true){
			super(asyncHandler, doAsynchronous);
			if(rule){
				singleUseRule = rule;
				addUniversalRule(rule);
				this.scopeDisplay = scopeDisplay;
			}
		}
		override public function execute(from:UniversalActExecution, params:Array):void{
			super.execute(from, params);
			if(singleUseRule){
				removeUniversalRule(singleUseRule);
				scopeDisplay = null;
				singleUseRule = null;
			}
		}
	}
}