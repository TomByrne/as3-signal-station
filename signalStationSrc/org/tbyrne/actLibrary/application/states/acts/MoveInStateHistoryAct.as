package org.tbyrne.actLibrary.application.states.acts
{
	import org.tbyrne.actLibrary.application.states.actTypes.IMoveInStateHistoryAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class MoveInStateHistoryAct extends UniversalAct implements IMoveInStateHistoryAct
	{
		
		public function get steps():int{
			return _steps;
		}
		public function set steps(value:int):void{
			_steps = value;
		}
		
		private var _steps:int;
		
		public function MoveInStateHistoryAct(steps:int=-1)
		{
			super();
			
			this.steps = steps;
		}
	}
}