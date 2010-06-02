package org.farmcode.acting.universal
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IAsynchronousAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.reactions.IActReaction;
	import org.farmcode.acting.universal.reactions.NestedExecutionReaction;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	import org.farmcode.acting.universal.rules.ImmediateActRule;
	import org.farmcode.flags.ValidationFlag;
	
	use namespace ActingNamspace;

	public class UniversalActExecutor
	{
		private static var pool:Array = new Array();
		
		ActingNamspace static function getNew():UniversalActExecutor{
			if(pool.length){
				return pool.shift();
			}else{
				return new UniversalActExecutor();
			}
		}
		
		
		public function UniversalActExecutor(){
			_reactors = new Array();
			_executions = new Dictionary();
			_executionCount = 0;
			_rules = new Dictionary();
		}
		
		private var _act:IUniversalAct
		private var _reactors:Array;
		private var _rules:Dictionary;
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
			for(var i:* in _executions){
				var execution:UniversalActExecution = (i as UniversalActExecution);
				execution.reactorsChanged();
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
		
		protected function onExecutionComplete(execution:UniversalActExecution):void{
			execution.completeAct.removeHandler(onExecutionComplete);
			delete _executions[execution];
			--_executionCount;
			if(!_executionCount && _executionsCompleted)_executionsCompleted.perform(this);
			execution.release();
		}
		protected function onActTrigger(endHandler:Function, parentExecution:UniversalActExecution=null, ... params):void{
			_reactorsValid.validate();
			var execution:UniversalActExecution = UniversalActExecution.getNew(_reactors,parentExecution,this,endHandler,params);
			execution.completeAct.addHandler(onExecutionComplete);
			_executions[execution] = true;
			++_executionCount;
			if(parentExecution){
				//TODO: Shouldn't this only be added to the parentExecution (and not the parentExecutor)?
				parentExecution.actExecutor.addReaction(new NestedExecutionReaction(execution),new ImmediateActRule());
			}else{
				execution.begin();
			}
		}
		private function validateReactors():void{
			if(_reactors.length){
				var newList:Array = [_reactors[0]];
				var newListCount:int = 1;
				var takenList:Array = [0];
				var index:int = 0;
				var taken:Boolean = false;
				while(takenList.length<_reactors.length){
					
					var search:Boolean = false;
					while(takenList.indexOf(index)!=-1 || !search){
						search = true;
						++index;
						if(index==_reactors.length){
							if(!taken){
								throw new Error("This list of IActReactions can not be ordered");
							}
							index = 0;
							taken = false;
						}
					}
					var reaction1:IActReaction = _reactors[index];
					
					var particlePositions:Dictionary = new Dictionary();
					
					var particleIndex:int = -1;
					for(var i:int=0; i<newListCount; i++){
						var reaction2:IActReaction = newList[i];
						if(shouldReactBefore(reaction1,reaction2)){
							if(particleIndex==-1){
								particleIndex = i;
							}else{
								throw new Error("IActReaction has a conflicting position in list.");
							}
						}
						if(shouldReactBefore(reaction2,reaction1)){
							if(particleIndex==-1){
								particleIndex = i+1;
							}else{
								throw new Error("IActReaction has a conflicting position in list.");
							}
						}
					}
					if(particleIndex!=-1){
						taken = true;
						newList.splice(particleIndex,0,reaction1);
						takenList.push(index);
						++newListCount;
					}
				}
				_reactors = newList;
			}
		}
		private function shouldReactBefore(reaction1:IActReaction, reaction2:IActReaction):Boolean{
			var rule:IUniversalRule;
			var rule1:IUniversalRule = _rules[reaction1];
			if(rule1.shouldReactBefore(act,reaction2)){
				return true;
			}
			var rule2:IUniversalRule = _rules[reaction2];
			if(rule2.shouldReactAfter(act,reaction1)){
				return true;
			}
			return false;
		}
		ActingNamspace function release():void{
			_reactors = new Array();
			_executions = new Dictionary();
			_rules = new Dictionary();
			_executionCount = 0;
			pool.push(this);
		}
	}
}