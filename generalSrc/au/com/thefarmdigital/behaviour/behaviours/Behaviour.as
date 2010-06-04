package au.com.thefarmdigital.behaviour.behaviours
{
	import au.com.thefarmdigital.behaviour.BehaviourEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class Behaviour extends EventDispatcher implements IBehaviour
	{
		public function get abortable():Boolean{
			return _abortable;
		}
		public function set abortable(value:Boolean):void{
			_abortable = value;
		}
		
		private var _abortable:Boolean;
		
		public function Behaviour()
		{
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
			dispatchEvent(new BehaviourEvent(BehaviourEvent.EXECUTION_COMPLETE));
		}
		
		public function finish():void
		{
		}
	}
}