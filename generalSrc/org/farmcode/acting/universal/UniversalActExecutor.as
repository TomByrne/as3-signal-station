package org.farmcode.acting.universal
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IAsynchronousAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	use namespace ActingNamspace;

	public class UniversalActExecutor
	{
		private static var pool:Array = new Array();
		
		ActingNamspace static function take():UniversalActExecutor{
			if(pool.length){
				return pool.shift();
			}else{
				return new UniversalActExecutor();
			}
		}
		ActingNamspace static function leave(executor:UniversalActExecutor):void{
			executor.reset();
			pool.push(executor);
		}
		
		
		public function UniversalActExecutor(){
			reset();
		}
		
		private var _act:IUniversalAct
		private var _asyncAct:IAsynchronousAct
		private var _executorList:Array;
		private var _executions:Dictionary = new Dictionary();
		private var _ignoreTrigger:Boolean;
		private var _executionCount:int;
		private var _executionsCompleted:Act;
		
		
		/**
		 * handler(from:UniversalActExecutor)
		 */
		public function get executionsCompleted():IAct{
			if(!_executionsCompleted)_executionsCompleted = new Act();
			return _executionsCompleted;
		}
		
		
		ActingNamspace function set act(value:IUniversalAct):void{
			if(_act!=value){
				if(_act){
					_act.removeHandler(onActTrigger);
				}
				_act = value;
				_asyncAct = (act as IAsynchronousAct);
				if(_act){
					_act.addHandler(onActTrigger);
				}
				
			}
		}
		ActingNamspace function get executionCount():int{
			return _executionCount;
		}
		ActingNamspace function get act():IUniversalAct{
			return _act;
		}
		ActingNamspace function get executorCount():uint{
			return _executorList.length;
		}
		ActingNamspace function getExecutor(index:uint):UniversalActExecutor{
			return _executorList[index];
		}
		ActingNamspace function addExecutor(actExecutor:UniversalActExecutor, rule:IUniversalRule):void{
			if(_executorList.indexOf(actExecutor)==-1){
				var beforeInstigator:Boolean = true;
				var afterInstigator:Boolean = false;
				for(var index:int=0; index<_executorList.length; ++index){
					var compExecutor:UniversalActExecutor = _executorList[index];
					if(compExecutor==this){
						beforeInstigator = false;
					}else if(!beforeInstigator && !afterInstigator){
						afterInstigator = true;
					}
					if(rule.shouldExecuteBefore(compExecutor.act,beforeInstigator,afterInstigator)){
						break;
					}
				}
				_executorList.splice(index,0,actExecutor);
				for(var i:* in _executions){
					var execution:UniversalActExecution = (i as UniversalActExecution);
					if(execution.index>index){
						execution.index++;
					}
				}
			}
		}
		ActingNamspace function removeExecutor(actExecutor:UniversalActExecutor):void{
			var index:int = _executorList.indexOf(actExecutor);
			if(index!=-1){
				_executorList.splice(index,1);
				for(var i:* in _executions){
					var execution:UniversalActExecution = (i as UniversalActExecution);
					if(execution.index>index){
						execution.index--;
					}
				}
			}
		}
		
		ActingNamspace function execute(endHandler:Function, from:UniversalActExecution, params:Array):void{
			if(_asyncAct){
				_asyncAct.execute(endHandler, params);
			}else{
				endHandler();
			}
		}
		ActingNamspace function trigger(endHandler:Function, parentExecution:UniversalActExecution, params:Array):void{
			var execution:UniversalActExecution = UniversalActExecution.take();
			execution.completeAct.addHandler(onExecutionComplete);
			_executions[execution] = true;
			++_executionCount;
			if(endHandler!=null){
				_ignoreTrigger = true;
				var realParams:Array = [execution];
				if(params.length)realParams = realParams.concat(params);
				act.universalPerform.apply(null,realParams);
				_ignoreTrigger = false;
			}
			execution.begin(parentExecution, this,endHandler,params);
		}
		protected function onExecutionComplete(execution:UniversalActExecution):void{
			execution.completeAct.removeHandler(onExecutionComplete);
			delete _executions[execution];
			--_executionCount;
			if(!_executionCount && _executionsCompleted)_executionsCompleted.perform(this);
			UniversalActExecution.leave(execution);
		}
		protected function onActTrigger(... params):void{
			if(!_ignoreTrigger){
				trigger.apply(null,[null,null,params]);
			}
		}
		public function reset():void{
			_executorList = new Array();
			_executorList.push(this);
			_executions = new Dictionary();
			_executionCount = 0;
		}
	}
}