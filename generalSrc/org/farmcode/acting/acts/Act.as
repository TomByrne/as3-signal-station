package org.farmcode.acting.acts
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	
	//TODO: pool Act class
	public class Act implements IAct
	{
		
		public function get handlerCount():int{
			return _handlerCount;
		}
		
		protected var _handlers:Array = new Array();
		protected var _handlerCount:int = 0;
		protected var _handlerIndices:Dictionary = new Dictionary();
		protected var _handlerExecCount:Dictionary = new Dictionary();
		
		protected var _performing:Boolean;
		protected var _removeAll:Boolean;
		protected var _toRemove:Array = new Array();
		
		public function Act(){
		}
		
		public function perform(... params):void{
			_performing = true;
			for each(var actHandler:ActHandler in _handlers){
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
						_toRemove.push(actHandler.handler);
					}
				}
			}
			_performing = false;
			var removeLength:int = (_toRemove.length);
			if(_removeAll || (removeLength && _toRemove.length==_handlers.length)){
				removeAllHandlers();
				_removeAll = false;
				if(removeLength)_toRemove = new Array();
			}else if(removeLength){
				for each(var handler:Function in _toRemove){
					removeHandler(handler);
				}
				_toRemove = new Array();
			}
		}
		
		public function addHandler(handler:Function, additionalArguments:Array=null):void{
			_addHandler(handler, additionalArguments, _handlerIndices, _handlers);
		}
		protected function _addHandler(handler:Function, additionalArguments:Array, handlerIndices:Dictionary, handlers:Array):ActHandler{
			var ret:ActHandler;
			if(handlerIndices[handler]==null){
				handlerIndices[handler] = handlers.length;
				ret = ActHandler.getNew(handler,additionalArguments);
				handlers.push(ret);
				setHandlerCount(++_handlerCount);
			}else{
				var index:int = handlerIndices[handler];
				ret = handlers[index];
			}
			return ret;
		}
		public function addTempHandler(handler:Function, additionalArguments:Array=null):void{
			var actHandler:ActHandler = _addHandler(handler, additionalArguments, _handlerIndices, _handlers);
			actHandler.executions = 1;
		}
		
		public function removeHandler(handler:Function):void{
			_removeHandler(handler, _handlerIndices, _handlers, _toRemove, _performing);
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
					setHandlerCount(--_handlerCount);
				}
			}
		}
		
		public function removeAllHandlers():void{
			if(_performing){
				_removeAll = true;
			}else{
				if(_handlers.length){
					_handlers = new Array();
					_handlerIndices = new Dictionary();
				}
				setHandlerCount(0);
			}
		}
		
		protected function setHandlerCount(value:int):void{
			_handlerCount = value;
		}
	}
}