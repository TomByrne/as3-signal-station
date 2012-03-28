package org.tbyrne.acting.acts
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.display.visualSockets.mappers.NullPlugMapper;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	
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
		
		
		public function get postponeRemoval():Boolean{
			return _postponeRemoval;
		}
		public function set postponeRemoval(value:Boolean):void{
			if(_postponeRemoval!=value){
				_postponeRemoval = value;
			}
		}
		
		private var _postponeRemoval:Boolean;
		
		protected var _handlers:Array = new Array();
		protected var _handlerCount:int = 0;
		protected var _handlerIndices:Dictionary = new Dictionary();
		protected var _handlerExecCount:Dictionary = new Dictionary();
		
		protected var _performing:Boolean;
		
		protected var _removeTracker:HandlerRemovalTracker = new HandlerRemovalTracker();
		
		public function Act(){
		}
		
		public function perform(... params):void{
			_performing = true;
			var hasParams:Boolean = (params.length>0);
			for each(var actHandler:ActHandler in _handlers){
				if((!actHandler.checkExecutions || actHandler.executions) && // if the event gets dispatched again as a result of a handler
					(_postponeRemoval || _removeTracker.removeHandlerCount==0 || !_removeTracker.removeHandlers[actHandler.handler])){
					
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
							_removeTracker.addRemove(actHandler.handler);
						}
					}
				}
			}
			_performing = false;
			checkRemove(_removeTracker, _handlerIndices, _handlers);
		}
		
		protected function checkRemove(removeTracker:HandlerRemovalTracker, handlerIndices:Dictionary, handlers:Array):void{
			if(removeTracker.checkRemove){
				if(removeTracker.removeAll || removeTracker.removeHandlerCount==_handlers.length){
					removeAllHandlers();
				}else if(removeTracker.removeHandlerCount){
					for(var handler:* in removeTracker.removeHandlers){
						_removeHandler(handler, handlerIndices, handlers, removeTracker, false);
					}
				}
				removeTracker.clear();
			}
		}
		
		public function addHandler(handler:Function, additionalArguments:Array=null):void{
			_addHandler(handler, additionalArguments, _handlerIndices, _handlers, _removeTracker);
		}
		protected function _addHandler(handler:Function, additionalArguments:Array, handlerIndices:Dictionary, handlers:Array, removeTracker:HandlerRemovalTracker):ActHandler{
			var ret:ActHandler;
			if(handlerIndices[handler]==null){
				handlerIndices[handler] = handlers.length;
				ret = ActHandler.getNew(handler,additionalArguments);
				handlers.push(ret);
				setHandlerCount(++_handlerCount);
			}else{
				if(_removeTracker.removeAll){
					// change from remove all to remove all but this handler
					_removeTracker.clear();
					for each(var actHandler:ActHandler in _handlers){
						if(actHandler.handler!=handler)removeTracker.addRemove(actHandler.handler);
					}
				}else{
					CONFIG::debug{
						if(!removeTracker.removeHandlerCount || !removeTracker.removeHandlers[handler])Log.log(Log.PERFORMANCE,"attempting to add handler twice (Act._addHandler())");
					}
					removeTracker.deleteRemove(handler);
				}
				var index:int = handlerIndices[handler];
				ret = handlers[index];
			}
			return ret;
		}
		public function addTempHandler(handler:Function, additionalArguments:Array=null):void{
			var actHandler:ActHandler = _addHandler(handler, additionalArguments, _handlerIndices, _handlers, _removeTracker);
			actHandler.executions = 1;
		}
		
		public function removeHandler(handler:Function):void{
			_removeHandler(handler, _handlerIndices, _handlers, _removeTracker, _performing);
		}
		protected function _removeHandler(handler:Function, handlerIndices:Dictionary, handlers:Array, removeTracker:HandlerRemovalTracker, performing:Boolean):void{
			var _index:* = handlerIndices[handler];
			if(_index!=null){
				if(performing){
					if(!removeTracker.removeAll)removeTracker.addRemove(handler);
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
				_removeTracker.removeAll = true;
			}else{
				if(_handlers.length){
					_handlers = new Array();
					_handlerIndices = new Dictionary();
				}
				_removeTracker.clear();
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