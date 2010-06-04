package au.com.thefarmdigital.debug.debugNodes.sodality
{
	import au.com.thefarmdigital.debug.debugNodes.AbstractDebugNode;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.utils.AdviceExecutionNode;
	
	public class AdviceExecutionDebugNode extends AbstractDebugNode
	{
		private static const PRE_EXECUTION_COLOUR:Number = 0xffffff;
		private static const EXECUTION_COLOUR:Number = 0xff0000;
		private static const POST_EXECUTION_COLOUR:Number = 0x999999;
		
		public function get adviceExecutionNode():AdviceExecutionNode{
			return _adviceExecutionNode;
		}
		public function set adviceExecutionNode(value:AdviceExecutionNode):void{
			if(_adviceExecutionNode!=value){
				if(_adviceExecutionNode){
					_adviceExecutionNode.advice.removeEventListener(AdviceEvent.EXECUTE, onBeginExecute);
					_adviceExecutionNode.advice.removeEventListener(AdviceEvent.CONTINUE, onBeginContinue);
					_adviceExecutionNode.removeEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
				}
				_adviceExecutionNode = value;
				setLabelColour(PRE_EXECUTION_COLOUR);
				if(_adviceExecutionNode){
					_label = getQualifiedClassName(_adviceExecutionNode.advice);
					var index:int = _label.indexOf("::");
					if(index!=-1){
						_label = _label.slice(index+2);
					}
					_adviceExecutionNode.advice.removeEventListener(AdviceEvent.EXECUTE, onBeginExecute);
					_adviceExecutionNode.advice.removeEventListener(AdviceEvent.CONTINUE, onBeginContinue);
					_adviceExecutionNode.addEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
				}
				dispatchNodeChange();
			}
		}
		override public function get label():String{
			return _label;
		}
		override public function get labelColour():Number{
			return _labelColour;
		}
		override public function set childNodes(value: Array): void{
			// ignore
		}
		
		private var _adviceExecutionNode:AdviceExecutionNode;
		private var _labelColour:Number;
		private var _label:String;
		private var _childMap:Dictionary = new Dictionary();
		
		public function AdviceExecutionDebugNode(adviceExecutionNode:AdviceExecutionNode){
			this.adviceExecutionNode = adviceExecutionNode;
			_childNodes = [];
		}
		protected function onBeginExecute(e:Event):void{
			setLabelColour(EXECUTION_COLOUR);
		}
		protected function onBeginContinue(e:Event):void{
			setLabelColour(POST_EXECUTION_COLOUR);
		}
		protected function onAdviceExecute(e:Event):void{
			var oldChildren:Array = _childNodes;
			_childNodes = [];
			var childExNode:AdviceExecutionNode;
			var childNode:AdviceExecutionDebugNode;
			var index:int;
			var i:int;
			
			for(i=0; i<_adviceExecutionNode.executeBefore.length; i++){
				childExNode = _adviceExecutionNode.executeBefore[i];
				childNode = _childMap[childExNode];
				if(!childNode){
					childNode = _childMap[childExNode] = new AdviceExecutionDebugNode(childExNode);
				}
				_childNodes.push(childNode);
			}
			for(i=0; i<_adviceExecutionNode.executeAfter.length; i++){
				childExNode = _adviceExecutionNode.executeAfter[i];
				childNode = _childMap[childExNode];
				if(!childNode){
					childNode = _childMap[childExNode] = new AdviceExecutionDebugNode(childExNode);
				}
				_childNodes.push(childNode);
			}
			for(i=0; i<oldChildren.length; i++){
				childNode = oldChildren[i];
				if(_childNodes.indexOf(childNode)==-1){
					delete _childMap[childNode.adviceExecutionNode];
					childNode.adviceExecutionNode = null;
				}
			}
			dispatchNodeChange();
		}
		
		
		protected function setLabelColour(value:Number):void{
			if(_labelColour!=value){
				_labelColour = value;
				dispatchNodeChange();
			}
		}
	}
}