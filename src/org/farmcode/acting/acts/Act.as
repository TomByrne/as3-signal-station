package org.farmcode.acting.acts
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	
	public class Act implements IAct
	{
		public function get handlerCount():int{
			return handlers.length;
		}
		
		private var handlers:Array = new Array();
		private var handlerIndices:Dictionary = new Dictionary();
		private var handlerExecCount:Dictionary = new Dictionary();
		
		private var performing:Boolean;
		private var removeAll:Boolean;
		private var toRemove:Array = new Array();
		
		public function Act(){
		}
		
		public function perform(... params):void{
			performing = true;
			for each(var actHandler:ActHandler in handlers){
				var thisParams:Array;
				if(actHandler.additionalArguments && actHandler.additionalArguments.length){
					thisParams = params.concat(actHandler.additionalArguments);
				}else{
					thisParams = params;
				}
				actHandler.handler.apply(null,thisParams);
				if(actHandler.executions>0){
					--actHandler.executions;
					if(actHandler.executions==0){
						toRemove.push(actHandler.handler);
					}
				}
			}
			performing = false;
			var removeLength:int = (toRemove.length);
			if(removeAll || (removeLength && toRemove.length==handlers.length)){
				removeAllHandlers();
				removeAll = false;
				if(removeLength)toRemove = new Array();
			}else if(removeLength){
				for each(var handler:Function in toRemove){
					removeHandler(handler);
				}
				toRemove = new Array();
			}
		}
		
		public function addHandler(handler:Function, additionalArguments:Array=null):void{
			_addHandler(handler, additionalArguments, handlerIndices, handlers);
		}
		protected function _addHandler(handler:Function, additionalArguments:Array, handlerIndices:Dictionary, handlers:Array):ActHandler{
			if(handlerIndices[handler]==null){
				handlerIndices[handler] = handlers.length;
				var ret:ActHandler = ActHandler.getNew(handler,additionalArguments);
				handlers.push(ret);
				return ret;
			}
			return null;
		}
		public function addTempHandler(handler:Function, additionalArguments:Array=null):void{
			var actHandler:ActHandler = _addHandler(handler, additionalArguments, handlerIndices, handlers);
			actHandler.executions = 1;
		}
		
		public function removeHandler(handler:Function):void{
			_removeHandler(handler, handlerIndices, handlers, toRemove, performing);
		}
		protected function _removeHandler(handler:Function, handlerIndices:Dictionary, handlers:Array, toRemove:Array, performing:Boolean):void{
			var _index:* = handlerIndices[handler];
			if(_index!=null){
				if(performing){
					toRemove.push(handler);
				}else{
					var index:int = int(_index);
					var actHandler:ActHandler = handlers.splice(index,1)[0];
					delete handlerIndices[actHandler.handler];
					actHandler.release();
					for(var i:int=index; i<handlers.length; i++){
						actHandler = handlers[i];
						handlerIndices[actHandler.handler] = i;
					}
				}
			}
		}
		
		public function removeAllHandlers():void{
			if(performing){
				removeAll = true;
			}else{
				if(handlers.length){
					handlers = new Array();
					handlerIndices = new Dictionary();
				}
			}
		}
	}
}

class ActHandler{
	private static const pool:Array = new Array();
	public static function getNew(handler:Function, additionalArguments:Array):ActHandler{
		if(pool.length){
			var ret:ActHandler = pool.shift();
			ret.handler = handler;
			ret.additionalArguments = additionalArguments;
			return ret;
		}else{
			return new ActHandler(handler, additionalArguments);
		}
	}
	
	public var handler:Function;
	public var additionalArguments:Array;
	public var executions:int = 0;
	
	public function ActHandler(handler:Function, additionalArguments:Array){
		this.handler = handler;
		this.additionalArguments = additionalArguments;
	}
	public function release():void{
		handler = null;
		additionalArguments = null;
		pool.unshift(this);
	}
}