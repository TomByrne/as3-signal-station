package org.tbyrne.actLibrary.core
{
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.reactions.MethodReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public class SingleMethodReaction extends MethodReaction
	{
		private var singleUseRule:IUniversalRule;
		
		public function SingleMethodReaction(scopeDisplay:IDisplayObject=null, asyncHandler:Function=null, rule:IUniversalRule=null, doAsynchronous:Boolean=true){
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