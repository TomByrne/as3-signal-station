package org.farmcode.acting.universal.reactions
{
	import org.farmcode.acting.universal.phases.LogicPhases;
	import org.farmcode.acting.universal.phases.ObjectPhases;
	import org.farmcode.acting.acts.AsynchronousAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	
	public class MethodReaction extends ActReaction
	{
		public var handler:Function;
		public var doAsynchronous:Boolean;
		public var passParameters:Boolean;
		public var passAct:Boolean;
		
		public function MethodReaction(handler:Function, doAsynchronous:Boolean=true){
			this.handler = handler;
			this.doAsynchronous = doAsynchronous;
			phases = [LogicPhases.CALL_FUNCTION];
		}
		override public function execute(from:UniversalActExecution, params:Array):void{
			if(handler!=null){
				var realParams:Array = (passAct?[from?from.act:null]:[]);
				if(passParameters && params.length){
					realParams = realParams.concat(params);
				}
				
				if(doAsynchronous){
					realParams.unshift(from);
					handler.apply(null,realParams);
				}else{
					handler.apply(null,realParams);
					from.continueExecution();
				}
			}else{
				from.continueExecution();
			}
		}
	}
}