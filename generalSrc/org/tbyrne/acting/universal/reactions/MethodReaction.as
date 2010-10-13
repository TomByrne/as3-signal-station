package org.tbyrne.acting.universal.reactions
{
	import org.tbyrne.acting.universal.phases.LogicPhases;
	import org.tbyrne.acting.universal.phases.ObjectPhases;
	import org.tbyrne.acting.acts.AsynchronousAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	
	public class MethodReaction extends ActReaction
	{
		public var handler:Function;
		public var doAsynchronous:Boolean;
		public var passParameters:Boolean;
		public var passAct:Boolean = true;
		
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