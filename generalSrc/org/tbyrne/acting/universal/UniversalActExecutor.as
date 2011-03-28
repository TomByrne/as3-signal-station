package org.tbyrne.acting.universal
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.universal.reactions.IActReaction;
	import org.tbyrne.acting.universal.reactions.NestedExecutionReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	import org.tbyrne.display.validation.ValidationFlag;
	
	use namespace ActingNamspace;

	public class UniversalActExecutor extends UniversalReactionSorter
	{
		private static var pool:Array = new Array();
		
		ActingNamspace static function getNew():UniversalActExecutor{
			if(pool.length){
				return pool.shift();
			}else{
				return new UniversalActExecutor();
			}
		}
		
		
		public function get executionsFrozen():Boolean{
			return _executionsFrozen;
		}
		public function set executionsFrozen(value:Boolean):void{
			if(_executionsFrozen!=value){
				_executionsFrozen = value;
				if(_executionsFrozen){
					_execReators = _reactors.concat();
					_execRules = copyDictionary(_rules);
				}else{
					_execReators = _reactors;
					_execRules = _rules;
				}
				setExecutionReactors();
			}
		}
		
		
		
		public function UniversalActExecutor(){
			_reactors = new Array();
			_executions = new Dictionary();
			_executionCount = 0;
			_rules = new Dictionary();
			_execReators = _reactors;
			_execRules = _rules;
		}
		private var _executionsFrozen:Boolean;
		private var _execReators:Array;
		private var _execRules:Dictionary;
		
		private var _reactors:Array;
		private var _rules:Dictionary;
		
		private var _act:IUniversalAct
		private var _executions:Dictionary;
		private var _executionCount:int;
		private var _executionsCompleted:Act;
		private var _reactorsValid:ValidationFlag = new ValidationFlag(validateReactors,false);
		
		
		/**
		 * handler(from:UniversalActExecutor)
		 */
		public function get executionsCompleted():IAct{
			if(!_executionsCompleted)_executionsCompleted = new Act();
			return _executionsCompleted;
		}
		
		ActingNamspace function get reactors():Array{
			_reactorsValid.validate();
			return _reactors;
		}
		
		ActingNamspace function set act(value:IUniversalAct):void{
			if(_act!=value){
				if(_act){
					_act.removeAsyncHandler(onActTrigger);
				}
				_act = value;
				if(_act){
					_act.addAsyncHandler(onActTrigger);
				}
				
			}
		}
		/**
		 * Amount of currently running executions
		 */
		ActingNamspace function get executionCount():int{
			return _executionCount;
		}
		ActingNamspace function get act():IUniversalAct{
			return _act;
		}
		ActingNamspace function addReaction(reaction:IActReaction, rule:IUniversalRule):void{
			if(_reactors.indexOf(reaction)==-1){
				_reactors.push(reaction);
				_rules[reaction] = rule;
				invalidateReactors();
			}
		}
		protected function invalidateReactors():void{
			_reactorsValid.invalidate();
			setExecutionReactors();
		}
		protected function setExecutionReactors():void{
			for(var i:* in _executions){
				var execution:UniversalActExecution = (i as UniversalActExecution);
				execution.setReactors(_execReators,_execRules);
			}
		}
		ActingNamspace function removeReaction(reaction:IActReaction):void{
			var index:int = _reactors.indexOf(reaction);
			if(index!=-1){
				_reactors.splice(index,1);
				delete _rules[reaction];
				invalidateReactors();
			}
		}
		ActingNamspace function removeAllReactions():void{
			_rules = new Dictionary();
			_reactors = [];
			invalidateReactors();
		}
		
		protected function onExecutionComplete(execution:UniversalActExecution):void{
			execution.completeAct.removeHandler(onExecutionComplete);
			delete _executions[execution];
			--_executionCount;
			if(!_executionCount && _executionsCompleted)_executionsCompleted.perform(this);
			execution.release();
		}
		protected function onActTrigger(endHandler:Function, parentExecution:UniversalActExecution=null, ... params):void{
			_reactorsValid.validate();
			var execution:UniversalActExecution = UniversalActExecution.getNew(parentExecution,this,endHandler,params);
			execution.setReactors(_execReators,_execRules);
			execution.completeAct.addHandler(onExecutionComplete);
			_executions[execution] = true;
			++_executionCount;
			CONFIG::debug{
				if(execution.reactionCount==0 && String(execution.act).indexOf("Method")==-1){
					Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"UniversalAct without reactions that doesn't appear to call a method: "+execution.act);
				}
			}
			if(parentExecution){
				var reaction:NestedExecutionReaction = new NestedExecutionReaction(execution);
				parentExecution.addReaction(reaction,reaction.immediateRule);
			}else{
				execution.begin();
			}
		}
		private function validateReactors():void{
			_reactors = sortReactions(act,_reactors,_rules);
			if(!_executionsFrozen)_execReators = _reactors;
		}
		ActingNamspace function release():void{
			act = null;
			_reactors = [];
			_executions = new Dictionary();
			_rules = new Dictionary();
			_executionCount = 0;
			_execReators = _reactors;
			_execRules = _rules;
			pool.push(this);
		}
	}
}