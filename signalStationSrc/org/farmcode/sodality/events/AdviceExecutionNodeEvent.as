package org.farmcode.sodality.events
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.utils.AdviceExecutionNode;
	
	import flash.events.Event;

	public class AdviceExecutionNodeEvent extends Event
	{
		public static const EXECUTE_ADVICE:String = "executeAdvice";
		
		[Property(toString="true",clonable="true")]
		public function get advice():IAdvice{
			return _advice;
		}
		public function set advice(value:IAdvice):void{
			//if(_advice != value){
				_advice = value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get targetNode():AdviceExecutionNode{
			return _targetNode;
		}
		public function set targetNode(value:AdviceExecutionNode):void{
			//if(_targetNode != value){
				_targetNode = value;
			//}
		}
		
		private var _targetNode:AdviceExecutionNode;
		private var _advice:IAdvice;
		
		public function AdviceExecutionNodeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		override public function clone():Event{
			var ret:AdviceExecutionNodeEvent = new AdviceExecutionNodeEvent(type,bubbles,cancelable);
			ret.advice = advice;
			ret.targetNode = targetNode;
			return ret;
		}
	}
}