package org.tbyrne.acting.universal
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.universal.UniversalActExecutor;
	import org.tbyrne.acting.universal.reactions.IActReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	import org.tbyrne.collections.DictionaryUtils;
	
	use namespace ActingNamspace;
	
	public class UniversalActExecution extends UniversalReactionSorter
	{
		private static var pool:Array = new Array();
		
		ActingNamspace static function getNew(parentExecution:UniversalActExecution, actExecutor:UniversalActExecutor, endHandler:Function, params:Array):UniversalActExecution{
			if(pool.length){
				var ret:UniversalActExecution = pool.shift();
				ret.init(parentExecution, actExecutor, endHandler, params);
				return ret;
			}else{
				return new UniversalActExecution(parentExecution, actExecutor, endHandler, params);
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
		private var _nestedEndHandler:Function;
		
		private var _rules:Dictionary;
		private var _reactors:Array;
		private var _extraRules:Dictionary;
		private var _extraReactors:Array;
		private var _compiledRules:Dictionary;
		private var _compiledReactors:Array;
		
		public function UniversalActExecution(parentExecution:UniversalActExecution, actExecutor:UniversalActExecutor, endHandler:Function, params:Array){
			init(parentExecution, actExecutor, endHandler, params);
		}
		ActingNamspace function init(parentExecution:UniversalActExecution, actExecutor:UniversalActExecutor, endHandler:Function, params:Array):void{
			_parentExecution = parentExecution;
			_actExecutor = actExecutor;
			_endHandler = endHandler;
			_params = params;
			_executed = new Dictionary();
		}
		ActingNamspace function begin(nestedEndHandler:Function=null):void{
			_index = 0;
			if(_indexChanged)_indexChanged.perform(this);
			_nestedEndHandler = nestedEndHandler;
			executeNext();
		}
		ActingNamspace function addReaction(reaction:IActReaction, rule:IUniversalRule):void{
			if(!_extraRules){
				_extraRules = new Dictionary();
				_extraReactors = [];
			}
			_extraRules[reaction] = rule;
			_extraReactors.push(reaction);
			compileExtraReactors();
		}
		public function continueExecution():void{
			if(_waiting){
				_waiting = false;
				executeNext();
			}else{
				Log.error( "UniversalActExecution.continueExecution: This execution is not waiting for continue() to be called");
			}
		}
		protected function executeNext():void{
			while(_index<_reactionCount){
				if(_executed[_compiledReactors[_index]]){
					++_index;
					if(_indexChanged)_indexChanged.perform(this);
				}else{
					break;
				}
			}
			if(_index<_reactionCount){
				var reaction:IActReaction = _compiledReactors[_index];
				_waiting = true;
				_executed[reaction] = true;
				reaction.execute(this,_params);
			}else{
				if(_endHandler!=null)_endHandler();
				if(_nestedEndHandler!=null)_nestedEndHandler();
				completeAct.perform(this);
			}
		}
		ActingNamspace function setReactors(reactors:Array, rules:Dictionary):void{
			_reactors = reactors;
			_rules = rules;
			if(_extraReactors){
				compileExtraReactors();
			}else{
				if(_index){
					_index = 0;
					if(_indexChanged)_indexChanged.perform(this);
				}
				_compiledReactors = _reactors;
				_compiledRules = _rules;
				if(_reactionCount!=_compiledReactors.length){
					_reactionCount = _compiledReactors.length;
					if(_reactionCountChanged)_reactionCountChanged.perform(this);
				}
			}
		}
		protected function compileExtraReactors():void{
			_compiledReactors = _reactors.concat();
			_compiledRules = copyDictionary(_rules);
			for each(var reactor:IActReaction in _extraReactors){
				_compiledReactors.push(reactor);
				_compiledRules[reactor] = _extraRules[reactor];
			}
			_compiledReactors = sortReactions(act, _compiledReactors,_compiledRules);
			
			if(_index){
				_index = 0;
				if(_indexChanged)_indexChanged.perform(this);
			}
			if(_reactionCount!=_compiledReactors.length){
				_reactionCount = _compiledReactors.length;
				if(_reactionCountChanged)_reactionCountChanged.perform(this);
			}
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
			_rules = null;
			_extraReactors = null;
			_extraRules = null;
			pool.push(this);
		}
	}
}