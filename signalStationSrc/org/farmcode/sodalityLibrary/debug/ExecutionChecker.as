package org.farmcode.sodalityLibrary.debug
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.IPresidentAwareAdvisor;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.utils.AdviceExecutionNode;
	
	use namespace SodalityNamespace;

	public class ExecutionChecker extends DynamicAdvisor implements IPresidentAwareAdvisor
	{
		public function get president():President{
			return _president;
		}
		public function set president(value:President):void{
			if(_president != value){
				if(_president){
					_president.removeEventListener(PresidentEvent.EXECUTION_BEGIN,onExecutionBegin);
					_president.removeEventListener(PresidentEvent.EXECUTION_END, onExecutionEnd);
				}
				_president = value;
				if(_president){
					_president.addEventListener(PresidentEvent.EXECUTION_BEGIN,onExecutionBegin,false,int.MAX_VALUE); // high priority to catch before it is processed.
					_president.addEventListener(PresidentEvent.EXECUTION_END, onExecutionEnd);
				}
			}
		}
		
		private var _president:President;
		private var openExecutions:Dictionary = new Dictionary(true);
		
		public function ExecutionChecker(advisorDisplay:DisplayObject=null){
			super();
			this.advisorDisplay = advisorDisplay;
		}
		protected function onExecutionBegin(e:PresidentEvent):void{
			openExecutions[e.adviceExecutionNode] = true;
		}
		protected function onExecutionEnd(e:PresidentEvent):void{
			delete openExecutions[e.adviceExecutionNode];
		}
		
		public function addPrintEventListener(dispatcher:IEventDispatcher, eventName:String):void{
			dispatcher.addEventListener(eventName,doPrint,false,0,true);
		}
		protected function doPrint(e:Event):void{
			printExecutingNodes();
		}
		public function printExecutingNodes():void{
			var _trace:String = ""
			for(var obj:* in openExecutions){
				_trace += "\n"+printNode(obj as AdviceExecutionNode);
			}
			trace(_trace);
		}
		protected function printNode(node:AdviceExecutionNode, tabs:String = ""):String{
			var ret:String = tabs+" "+node.advice;
			if(node.cursor && node.cursor!=node){
				ret += "\n"+printNode(node.cursor,tabs+"\t");
			}
			return ret;
		}
	}
}