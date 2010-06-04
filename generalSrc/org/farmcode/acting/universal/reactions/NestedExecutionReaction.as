package org.farmcode.acting.universal.reactions
{
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.rules.ImmediateActRule;
	
	use namespace ActingNamspace;

	public class NestedExecutionReaction extends ActReaction
	{
		private var _execution:UniversalActExecution;
		
		public function NestedExecutionReaction(execution:UniversalActExecution){
			super();
			_execution = execution;
			addUniversalRule(new ImmediateActRule());
		}
		
		override public function execute(from:UniversalActExecution, params:Array):void{
			_execution.begin(from.continueExecution);
		}
	}
}