package org.farmcode.sodality.threading
{
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.utils.AdviceExecutionNode;
	
	use namespace SodalityNamespace;
	
	internal class PresidentListener
	{
		public function get threadCount():uint{
			return threads.length;
		}
		
		private var _president:President;
		private var oldPostpone:Boolean = false;
		private var oldDispatch:Boolean = false;
		private var threads:Array = [];
		
		public function PresidentListener(president:President){
			_president = president;
			oldPostpone = _president.postponeExecution;
			oldDispatch = _president.dispatchEvents;
			_president.postponeExecution = true;
			_president.dispatchEvents = true;
			_president.addEventListener(PresidentEvent.EXECUTION_BEGIN, onAdviceExecute);
			_president.addEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
		}
		public function addThread(thread:PresidentThread):void{
			if(threads.indexOf(thread)==-1){
				threads.push(thread);
			}
		}
		public function removeThread(thread:PresidentThread):void{
			var index:Number = threads.indexOf(thread);
			if(index!=-1){
				threads.splice(index,1);
			}
		}
		public function destroy():void{
			_president.postponeExecution = oldPostpone;
			_president.dispatchEvents = oldDispatch;
			_president.removeEventListener(PresidentEvent.EXECUTION_BEGIN, onAdviceExecute);
			_president.removeEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
		}
		protected function onAdviceExecute(e:PresidentEvent):void{
			var adviceThreadId:String = getAdviceThreadId(e.adviceExecutionNode);
			if(threads.length){
				var thread: PresidentThread = this.getThreadById(adviceThreadId); //, true);
				if(thread){
					thread.addPresidentEvent(e);
				}else{
					e.continueExecution();
				}
			}
		}
		
		protected function getThreadById(threadId: String, searchForDefault: Boolean = false, 
			defaultTo: String = null): PresidentThread
		{
			var thread:PresidentThread = null;
			for(var i: uint=0; i<threads.length && thread == null; ++i){
				var testThread:PresidentThread = threads[i];
				if(testThread.threadId == threadId){
					thread = testThread;
				}
			}
			
			if (thread == null && searchForDefault)
			{
				thread = this.getThreadById(defaultTo);
			}
			
			return thread;
		}
		
		protected function getAdviceThreadId(node:AdviceExecutionNode):String{
			while(node){
				var threadAdvice:IThreadAdvice = (node.advice as IThreadAdvice);
				if(threadAdvice){
					return threadAdvice.threadId;
				}
				var mapped:String = PresidentThread.getTypeMapping(node.advice);
				if(mapped){
					return mapped;
				}
				node = node.parent;
			}
			return null;
		}
	}
}