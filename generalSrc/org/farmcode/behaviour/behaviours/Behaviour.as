package org.farmcode.behaviour.behaviours
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;

	public class Behaviour implements IBehaviour
	{
		public function get abortable():Boolean{
			return _abortable;
		}
		public function set abortable(value:Boolean):void{
			_abortable = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get executionComplete():IAct{
			if(!_executionComplete)_executionComplete = new Act();
			return _executionComplete;
		}
		
		protected var _executionComplete:Act;
		private var _abortable:Boolean;
		
		public function Behaviour(){
			super();
		}
		
		public function execute(goals:Array):Boolean{
			return false;
		}
		
		public function cancel():void{
			this.completeEarly();
		}
		
		protected function completeEarly():void
		{
			if(_executionComplete)_executionComplete.perform(this);
		}
		
		public function finish():void
		{
		}
	}
}