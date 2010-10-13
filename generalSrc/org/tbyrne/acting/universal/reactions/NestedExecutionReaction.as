package org.tbyrne.acting.universal.reactions
{
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.rules.ImmediateActRule;
	
	use namespace ActingNamspace;

	public class NestedExecutionReaction extends ActReaction
	{
		public function get immediateRule():ImmediateActRule{
			return _immediateRule;
		}
		
		private var _immediateRule:ImmediateActRule;
		private var _execution:UniversalActExecution;
		
		public function NestedExecutionReaction(execution:UniversalActExecution){
			super();
			_execution = execution;
			_immediateRule = new ImmediateActRule();
			addUniversalRule(_immediateRule);
		}
		
		override public function execute(from:UniversalActExecution, params:Array):void{
			_execution.begin(from.continueExecution);
		}
	}
}