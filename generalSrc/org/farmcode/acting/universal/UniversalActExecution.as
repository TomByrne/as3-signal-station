package org.farmcode.acting.universal
{
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.UniversalActExecutor;
	
	use namespace ActingNamspace;
	
	public class UniversalActExecution{
		private static var pool:Array = new Array();
		
		ActingNamspace static function take():UniversalActExecution{
			if(pool.length){
				return pool.shift();
			}else{
				return new UniversalActExecution();
			}
		}
		ActingNamspace static function leave(execution:UniversalActExecution):void{
			execution.reset();
			pool.push(execution);
		}
		
		
		public function get parent():UniversalActExecution{
			return _parent;
		}
		public function get act():IUniversalAct{
			return actExecutor.act;
		}
		public function get executorCount():int{
			return actExecutor.executorCount;
		}
		
		ActingNamspace var completeAct:Act = new Act();
		ActingNamspace var index:uint = 0;
		
		private var actExecutor:UniversalActExecutor;
		private var endHandler:Function;
		private var params:Array;
		private var _parent:UniversalActExecution;
		
		private var atInstigator:Boolean;
		
		ActingNamspace function begin(parent:UniversalActExecution, actExecutor:UniversalActExecutor, endHandler:Function, params:Array):void{
			this.actExecutor = actExecutor;
			this.endHandler = endHandler;
			this.params = params;
			_parent = parent;
			index = 0;
			executeNext();
		}
		protected function executeNext():void{
			if(index<actExecutor.executorCount){
				var executor:UniversalActExecutor = actExecutor.getExecutor(index);
				atInstigator = (actExecutor==executor);
				index++;
				if(atInstigator){
					executor.execute(executeNext,this,params);
				}else{
					executor.trigger(executeNext,this,params);
				}
			}else{
				if(endHandler!=null)endHandler();
				completeAct.perform(this);
			}
		}
		public function reset():void{
			index = 0;
			actExecutor = null;
			endHandler = null;
			_parent = null;
			atInstigator = false;
		}
	}
}