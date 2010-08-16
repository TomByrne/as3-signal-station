package org.farmcode.acting.acts
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.hoborg.ObjectPool;
	
	public class Act implements IAct, IPoolable
	{
		private static const pool:ObjectPool = new ObjectPool(Act);
		public static function getNew():Act{
			var ret:Act = pool.takeObject();
			return ret;
		}
		
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
		protected var _checkRemove:Boolean;
		
		public function Act(){
		}
		
		public function perform(... params):void{
			_checkRemove = false;
			_performing = true;
			var hasParams:Boolean = (params.length>0);
			for each(var actHandler:ActHandler in _handlers){
				if(actHandler.additionalArguments && actHandler.additionalArguments.length){
					if(hasParams){
						actHandler.handler.apply(null,params.concat(actHandler.additionalArguments));
					}else{
						actHandler.handler.apply(null,actHandler.additionalArguments);
					}
				}else if(hasParams){
					actHandler.handler.apply(null,params);
				}else{
					actHandler.handler();
				}
				if(actHandler.checkExecutions){
					--actHandler.executions;
					if(actHandler.executions==0){
						_toRemove.push(actHandler.handler);
						_checkRemove = true;
					}
				}
			}
			_performing = false;
			if(_checkRemove){
				var toRemoveCount:int = _toRemove.length;
				if(_removeAll || toRemoveCount==_handlers.length){
					removeAllHandlers();
					_removeAll = false;
				}else if(toRemoveCount){
					for each(var handler:Function in _toRemove){
						removeHandler(handler);
					}
					_toRemove = new Array();
				}
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
					_checkRemove = true;
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
		
		public function reset():void{
			removeAllHandlers();
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}