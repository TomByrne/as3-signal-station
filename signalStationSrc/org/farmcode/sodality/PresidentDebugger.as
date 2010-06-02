package org.farmcode.sodality
{
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.utils.AdviceExecutionNode;
	import org.farmcode.sodality.utils.AdvisorBundle;
	use namespace SodalityNamespace;
	
	public class PresidentDebugger
	{
		public function set president(value:President):void{
			if(_president!=value){
				if(_president){
					_president.dispatchEvents = _wasDispatcher;
					_president.removeEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
					_president.removeEventListener(PresidentEvent.ADVISOR_ADDED, onAdvisorAdded);
					_president.removeEventListener(PresidentEvent.ADVISOR_REMOVED, onAdvisorRemoved);
					_president.removeEventListener(PresidentEvent.EXECUTION_BEGIN, onExecutionBegin);
					_president.removeEventListener(PresidentEvent.EXECUTION_END, onExecutionEnd);
				}
				_president = value;
				if(_president){
					_wasDispatcher = _president.dispatchEvents;
					_president.dispatchEvents = true;
					_president.addEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
					_president.addEventListener(PresidentEvent.ADVISOR_ADDED, onAdvisorAdded);
					_president.addEventListener(PresidentEvent.ADVISOR_REMOVED, onAdvisorRemoved);
					_president.addEventListener(PresidentEvent.EXECUTION_BEGIN, onExecutionBegin);
					_president.addEventListener(PresidentEvent.EXECUTION_END, onExecutionEnd);
				}
			}
		}
		public function get president():President{
			return _president;
		}
		
		public var textArea:*;
		public var textAreaField:String = "text";
		public var doTrace:Boolean = true;
		
		protected var _wasDispatcher:Boolean;
		protected var _president:President;
		
		public function PresidentDebugger(president:President):void{
			this.president = president;
		}
		protected function debug(... rest):void{
			var string:String = "";
			for each(var item:* in rest){
				var itemStr:String = item.toString();
				if(itemStr.length){
					if(string.length)string += " ";
					string += itemStr;
				}
			}
			if(string.length){
				if(doTrace)trace(string);
				if(textArea){
					if((textArea[textAreaField] as String).length){
						string = "\n"+string;
					}
					textArea[textAreaField] += string;
				}
			}
		}
		
		protected function onAdviceExecute(e:PresidentEvent):void{
			var node:AdviceExecutionNode = e.adviceExecutionNode.parent;
			if(node){
				var tabs:String = "";
				while(node){
					tabs += "\t";
					node = node.parent;
				}
				debug(tabs+"onAdviceExecute: "+e.advice);
			}else{
				debug("onAdviceExecute: "+e.advice);
			}
		}
		protected function onAdvisorAdded(e:PresidentEvent):void{
			var bundle: AdvisorBundle = this.president.getBundleForAdvisor(e.advisor);
			debug("onAdvisorAdded: "+e.advisor + "\n  triggers[" + bundle.triggers.length + "]: " + bundle.triggers);
			debug(this.president.advisorRoot.describeTreeSimple(" "));
		}
		protected function onAdvisorRemoved(e:PresidentEvent):void{
			debug("onAdvisorRemoved: "+e.advisor);
		}
		protected function onExecutionBegin(e:PresidentEvent):void{
			var node:AdviceExecutionNode = e.adviceExecutionNode.parent;
			if(!node){
				debug("---\nonExecutionBegin: "+e.advice);
			}
		}
		protected function onExecutionEnd(e:PresidentEvent):void{
			var node:AdviceExecutionNode = e.adviceExecutionNode.parent;
			if(!node){
				debug("onExecutionEnd: "+e.advice+"\n---");
			}
		}
	}
}