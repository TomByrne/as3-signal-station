package au.com.thefarmdigital.debug.debugNodes.sodality
{
	import au.com.thefarmdigital.debug.debugNodes.AbstractDebugNode;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.events.PresidentEvent;
	
	use namespace SodalityNamespace;

	public class PendingExecutionDebugNode extends AbstractDebugNode
	{
		[Property(clonable="true")]
		public function get outputFormat(): String{
			return this._outputFormat;
		}
		public function set outputFormat(value: String): void{
			this._outputFormat = value;
		}
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
		override public function get label():String{
			var ret:String;
			if(_outputFormat){
				ret = _outputFormat.replace("%s",_totalCount);
			}else{
				ret = String(_totalCount);
			}
			return ret;
		}
		override public function set childNodes(value: Array): void{
			// ignore
		}
		
		private var _president:President;
		private var _outputFormat:String;
		private var _childMapping:Dictionary = new Dictionary();
		
		private var _totalCount:int = 0;
		
		public function PendingExecutionDebugNode(president:President=null, outputFormat:String=null)
		{
			this.president = president;
			this.outputFormat = outputFormat;
			_childNodes = [];
		}
		protected function onExecutionBegin(e:PresidentEvent):void{
			var advice:IAdvice = e.adviceExecutionNode.advice;
			var node:AdviceExecutionDebugNode = new AdviceExecutionDebugNode(e.adviceExecutionNode);
			_childMapping[advice] = node;
			_totalCount++;
			
			_childNodes.push(node);
			dispatchNodeChange();
		}
		protected function onExecutionEnd(e:PresidentEvent):void{
			var advice:IAdvice = e.adviceExecutionNode.advice;
			var node:AdviceExecutionDebugNode = _childMapping[advice]
			_totalCount--;
			
			var index:int = _childNodes.indexOf(node);
			_childNodes.splice(index,1);
			dispatchNodeChange();
		}
	}
}