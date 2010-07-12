package org.farmcode.actLibrary.core.acts
{
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	import org.farmcode.display.assets.IDisplayAsset;
	
	public class SingleMethodReaction extends MethodReaction
	{
		private var singleUseRule:IUniversalRule;
		
		public function SingleMethodReaction(scopeDisplay:IDisplayAsset=null, asyncHandler:Function=null, rule:IUniversalRule=null, doAsynchronous:Boolean=true){
			super(asyncHandler, doAsynchronous);
			if(rule){
				singleUseRule = rule;
				addUniversalRule(rule);
				this.asset = scopeDisplay;
			}
		}
		override public function execute(from:UniversalActExecution, params:Array):void{
			super.execute(from, params);
			if(singleUseRule){
				removeUniversalRule(singleUseRule);
				asset = null;
				singleUseRule = null;
			}
		}
	}
}