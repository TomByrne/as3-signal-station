package org.farmcode.acting.universal
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.UniversalActExecutor;
	import org.farmcode.acting.universal.reactions.IActReaction;
	
	use namespace ActingNamspace;
	
	public class UniversalActExecution{
		private static var pool:Array = new Array();
		
		ActingNamspace static function getNew(reactors:Array, parentExecution:UniversalActExecution, actExecutor:UniversalActExecutor, endHandler:Function, params:Array):UniversalActExecution{
			if(pool.length){
				var ret:UniversalActExecution = pool.shift();
				ret.init(reactors, parentExecution, actExecutor, endHandler, params);
				return ret;
			}else{
				return new UniversalActExecution(reactors, parentExecution, actExecutor, endHandler, params);
			}
		}
		
		
		
		ActingNamspace function get parentExecution():UniversalActExecution{
			return _parentExecution;
		}
		ActingNamspace function get actExecutor():UniversalActExecutor{
			return _actExecutor;
		}
		public function get act():IUniversalAct{
			return _actExecutor.act;
		}
		public function get reactionCount():int{
			return _reactionCount;
		}
		public function get index():int{
			return _index;
		}
		
		
		/**
		 * handler(from:UniversalActExecution)
		 */
		public function get indexChanged():IAct{
			if(!_indexChanged)_indexChanged = new Act();
			return _indexChanged;
		}
		
		/**
		 * handler(from:UniversalActExecution)
		 */
		public function get reactionCountChanged():IAct{
			if(!_reactionCountChanged)_reactionCountChanged = new Act();
			return _reactionCountChanged;
		}
		
		protected var _reactionCountChanged:Act;
		protected var _indexChanged:Act;
		
		/**
		 * handler(execution:UniversalActExecution);
		 */
		ActingNamspace var completeAct:Act = new Act();
		
		private var _index:uint = 0;
		private var _actExecutor:UniversalActExecutor;
		private var _endHandler:Function;
		private var _params:Array;
		private var _parentExecution:UniversalActExecution;
		private var _reactionCount:int;
		private var _waiting:Boolean;
		private var _executed:Dictionary;
		private var _reactors:Array;
		private var _nestedEndHandler:Function;
		
		public function UniversalActExecution(reactors:Array, parentExecution:UniversalActExecution, actExecutor:UniversalActExecutor, endHandler:Function, params:Array){
			init(reactors, parentExecution, actExecutor, endHandler, params);
		}
		ActingNamspace function init(reactors:Array, parentExecution:UniversalActExecution, actExecutor:UniversalActExecutor, endHandler:Function, params:Array):void{
			_reactors = reactors;
			_parentExecution = parentExecution;
			_actExecutor = actExecutor;
			_endHandler = endHandler;
			_params = params;
			_reactionCount = reactors.length;
			if(_reactionCountChanged)_reactionCountChanged.perform(this);
			_executed = new Dictionary();
		}
		ActingNamspace function begin(nestedEndHandler:Function=null):void{
			_index = 0;
			if(_indexChanged)_indexChanged.perform(this);
			_nestedEndHandler = nestedEndHandler;
			executeNext();
		}
		public function continueExecution():void{
			if(_waiting){
				_waiting = false;
				executeNext();
			}else{
				throw new Error("This execution is not waiting for continue() to be called");
			}
		}
		protected function executeNext():void{
			while(_index<_reactionCount){
				if(_executed[_reactors[_index]]){
					++_index;
					if(_indexChanged)_indexChanged.perform(this);
				}else{
					break;
				}
			}
			if(_index<_reactionCount){
				var reaction:IActReaction = _reactors[_index];
				_waiting = true;
				_executed[reaction] = true;
				reaction.execute(this,_params);
			}else{
				if(_endHandler!=null)_endHandler();
				if(_nestedEndHandler!=null)_nestedEndHandler();
				completeAct.perform(this);
			}
		}
		ActingNamspace function reactorsChanged():void{
			_index = 0;
			if(_indexChanged)_indexChanged.perform(this);
			_reactionCount = _reactors.length;
			if(_reactionCountChanged)_reactionCountChanged.perform(this);
		}
		ActingNamspace function release():void{
			if(_indexChanged){
				_indexChanged.removeAllHandlers();
				_indexChanged = null;
			}
			if(_reactionCountChanged){
				_reactionCountChanged.removeAllHandlers();
				_reactionCountChanged = null;
			}
			_index = 0;
			_actExecutor = null;
			_endHandler = null;
			_nestedEndHandler = null;
			_parentExecution = null;
			_executed = null;
			pool.push(this);
		}
	}
}