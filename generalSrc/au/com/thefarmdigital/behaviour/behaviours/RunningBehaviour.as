package au.com.thefarmdigital.behaviour.behaviours
{
	

	public class RunningBehaviour extends Behaviour
	{
		private var _running: Boolean;
		private var _complete: Boolean;
		
		public function RunningBehaviour()
		{
			super();
			
			this._running = false;
			this._complete = false;
		}
		
		protected function get running(): Boolean
		{
			return this._running;
		}
		
		final override public function execute(goals:Array):Boolean{
			var result: Boolean = this.executeGoals(goals);
			this._running = !result;
			this._complete = result;
			if (!result)
			{
				this.dispose();
			}
			return result;
		}
		
		protected function executeGoals(goals: Array): Boolean
		{
			return false;
		}
		
		override protected function completeEarly():void
		{
			this._complete = true;
			this.dispose();
			super.completeEarly();
		}
		
		override public function finish():void
		{
			this._running = false;
			this._complete = true;
			this.dispose();
		}
		
		protected function dispose(): void
		{
			
		}
	}
}