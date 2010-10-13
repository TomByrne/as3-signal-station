package org.tbyrne.acting.acts
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAsynchronousAct;
	
	public class AsynchronousAct extends Act implements IAsynchronousAct
	{
		private var asyncHandlers:Array = new Array();
		private var asyncHandlerIndices:Dictionary = new Dictionary();
		
		private var performingStacks:Array = [];
		private var removeAllAsync:Boolean;
		private var toRemoveAsync:Array = new Array();
		
		public function AsynchronousAct(){
			super();
		}
		
		override public function perform(... params) : void{
			super.perform.apply(null,params);
			if(asyncHandlers.length){
				var stack:AsyncHandlerStack = AsyncHandlerStack.getNew(asyncHandlers, params);
				stack.completeAct.addHandler(onStackFinish);
				performingStacks.push(stack);
				stack.begin();
			}
		}
		protected function onStackFinish(stack:AsyncHandlerStack) : void{
			var index:int = performingStacks.indexOf(stack);
			performingStacks.splice(index,1);
			
			if(!performingStacks.length){
				if(removeAllAsync || toRemoveAsync.length==asyncHandlers.length){
					removeAllAsyncHandlers();
					removeAllAsync = false;
				}else if(toRemoveAsync.length){
					for each(var handler:Function in toRemoveAsync){
						removeAsyncHandler(handler);
					}
					toRemoveAsync = new Array();
				}
			}
		}
		
		public function addAsyncHandler(handler:Function, additionalArguments:Array=null):void{
			_addHandler(handler, additionalArguments, asyncHandlerIndices, asyncHandlers);
		}
		
		public function removeAsyncHandler(handler:Function):void{
			_removeHandler(handler, asyncHandlerIndices, asyncHandlers, toRemoveAsync, performingStacks.length>0);
		}
		
		public function removeAllAsyncHandlers():void{
			if(performingStacks.length>0){
				removeAllAsync = true;
			}else{
				if(asyncHandlers.length){
					asyncHandlers = new Array();
					asyncHandlerIndices = new Dictionary();
				}
			}
		}
	}
}
import org.tbyrne.acting.acts.Act;

class AsyncHandlerStack{
	private static const pool:Array = new Array();
	public static function getNew(asyncHandlers:Array, params:Array):AsyncHandlerStack{
		if(pool.length){
			var ret:AsyncHandlerStack = pool.shift();
			ret.asyncHandlers = asyncHandlers;
			ret.params = params;
			return ret;
		}else{
			return new AsyncHandlerStack(asyncHandlers, params);
		}
	}
	
	public var asyncHandlers:Array;
	public var params:Array;
	public var realParams:Array;
	public var completeAct:Act = new Act();
	public var currentIndex:int;
	
	public function AsyncHandlerStack(asyncHandlers:Array, params:Array){
		this.asyncHandlers = asyncHandlers;
		this.params = params;
	}
	public function begin():void{
		currentIndex = 0;
		realParams = [doNext];
		if(params.length)realParams = realParams.concat(params);
		doNext();
	}
	private function doNext():void{
		if(currentIndex<asyncHandlers.length){
			var actHandler:Object = asyncHandlers[currentIndex];
			++currentIndex;
			
			var thisParams:Array;
			if(actHandler.additionalArguments && actHandler.additionalArguments.length){
				thisParams = realParams.concat(actHandler.additionalArguments);
			}else{
				thisParams = realParams;
			}
			actHandler.handler.apply(null,thisParams);
		}else{
			completeAct.perform(this);
		}
	}
	public function release():void{
		asyncHandlers = null;
		params = null;
		pool.unshift(this);
	}
}