package org.farmcode.acting.universal
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IAsynchronousAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	use namespace ActingNamspace;

	public class UniversalActManager
	{
		
		private static var managers:Dictionary = new Dictionary();
		private static var actMap:Dictionary = new Dictionary();
		
		
		public static function addManager(scopeDisplay:DisplayObject=null):void{
			if(managers[scopeDisplay]){
				throw new Error("Manager already added");
			}else{
				var parent:UniversalActManager = findManagerFor(scopeDisplay,false);
				var manager:UniversalActManager = new UniversalActManager();
				managers[scopeDisplay] = manager;
				if(parent){
					for each(var act:IUniversalAct in parent.acts){
						if(findManagerFor(act.scopeDisplay,false)==manager){
							parent.removeAct(act);
							manager.addAct(act);
							actMap[act] = manager;
						}
					}
				}
			}
		}
		public static function removeManager(scopeDisplay:DisplayObject):void{
			if(scopeDisplay){
				var subject:DisplayObject = scopeDisplay;
				while(subject){
					var manager:UniversalActManager = managers[subject];
					if(manager){
						delete managers[subject];
						
						var parent:UniversalActManager = findManagerFor(scopeDisplay,true);
						for each(var act:IUniversalAct in manager.acts){
							manager.removeAct(act);
							parent.addAct(act);
							actMap[act] = parent;
						}
						return;
					}
					subject = subject.parent;
				}
			}
			throw new Error("Can't remove base UniversalActManager");
		}
		public static function addAct(act:IUniversalAct):void{
			if(!actMap[act]){
				var manager:UniversalActManager = findManagerFor(act.scopeDisplay,true);
				manager.addAct(act);
				act.scopeDisplayChangeAct.addHandler(onScopeDisplayChange);
				actMap[act] = manager;
			}else{
				throw new Error("act already added");
			}
		}
		public static function removeAct(act:IUniversalAct):void{
			var manager:UniversalActManager = actMap[act];
			if(manager){
				manager.removeAct(act);
				act.scopeDisplayChangeAct.removeHandler(onScopeDisplayChange);
				delete actMap[act];
			}else{
				throw new Error("act has not been added");
			}
		}
		private static function findManagerFor(scopeDisplay:DisplayObject, createRoot:Boolean):UniversalActManager{
			var manager:UniversalActManager;
			if(scopeDisplay){
				var subject:DisplayObject = scopeDisplay;
				while(subject){
					manager = managers[subject];
					if(manager)return manager;
					subject = subject.parent;
				}
			}
			if(createRoot){
				manager = new UniversalActManager();
				managers[null] = manager;
				return manager;
			}
			return null;
		}
		private static function onScopeDisplayChange(act:IUniversalAct):void{
			var oldManager:UniversalActManager = actMap[act];
			var newManager:UniversalActManager = findManagerFor(act.scopeDisplay, true);
			if(oldManager!=newManager){
				oldManager.removeAct(act);
				newManager.addAct(act);
				actMap[act] = newManager;
			}
		}
		
		
		public function UniversalActManager(){
		}
		internal var acts:Dictionary = new Dictionary();
		internal var pendingRemoveActs:Dictionary = new Dictionary();
		
		public function addAct(act:IUniversalAct):void{
			var actExecutor:UniversalActExecutor = acts[act];
			if(!actExecutor){
				var executor:UniversalActExecutor = UniversalActExecutor.take();
				executor.act = act;
				for(var i:* in acts){
					var otherAct:IUniversalAct = (i as IUniversalAct);
					var childExecutor:UniversalActExecutor = acts[otherAct];
					for each(var otherRule:IUniversalRule in otherAct.universalRules){
						tryAddRule(executor, childExecutor, otherRule);
					}
					for each(var rule:IUniversalRule in act.universalRules){
						tryAddRule(childExecutor, executor, rule);
					}
				}
				acts[act] = executor;
				var asyncAct:IAsynchronousAct = (act as IAsynchronousAct);
				if(asyncAct){
					asyncAct.allowAutoExecute = false;
				}
				act.universalRuleAddedAct.addHandler(onRuleAdded);
				act.universalRuleRemovedAct.addHandler(onRuleRemoved);
			}else if(pendingRemoveActs[actExecutor]){
				delete pendingRemoveActs[actExecutor];
				actExecutor.executionsCompleted.removeHandler(onExecutorComplete);
			}else{
				throw new Error("This Act has already been added to this UniversalActManager");
			}
		}
		public function removeAct(act:IUniversalAct):void{
			var actExecutor:UniversalActExecutor = acts[act];
			if(actExecutor){
				if(!pendingRemoveActs[actExecutor]){
					if(!actExecutor.executionCount){
						_removeAct(act, actExecutor);
					}else{
						pendingRemoveActs[actExecutor] = true;
						actExecutor.executionsCompleted.addHandler(onExecutorComplete);
					}
				}else{
					throw new Error("This act has already been scheduled to be removed");
				}
			}else{
				throw new Error("This act doesn't exist within this UniversalActManager");
			}
		}
		protected function _removeAct(act:IUniversalAct, actExecutor:UniversalActExecutor):void{
			UniversalActExecutor.leave(actExecutor);
			delete acts[act];
			var asyncAct:IAsynchronousAct = (act as IAsynchronousAct);
			if(asyncAct){
				asyncAct.allowAutoExecute = true;
			}
			act.universalRuleAddedAct.removeHandler(onRuleAdded);
			act.universalRuleRemovedAct.removeHandler(onRuleRemoved);
		}
		protected function onExecutorComplete(actExecutor:UniversalActExecutor):void{
			_removeAct(actExecutor.act,actExecutor);
		}
		protected function onRuleAdded(universalAct:IUniversalAct, rule:IUniversalRule):void{
			var childExecutor:UniversalActExecutor = acts[universalAct];
			for each(var executor:UniversalActExecutor in acts){
				tryAddRule(executor, childExecutor, rule);
			}
		}
		protected function onRuleRemoved(universalAct:IUniversalAct, rule:IUniversalRule):void{
			var childExecutor:UniversalActExecutor = acts[universalAct];
			for each(var executor:UniversalActExecutor in acts){
				executor.removeExecutor(childExecutor);
			}
		}
		protected function tryAddRule(parentExecutor:UniversalActExecutor, childExecutor:UniversalActExecutor, rule:IUniversalRule):void{
			if(parentExecutor!= childExecutor){
				if(rule.shouldExecute(parentExecutor.act)){
					parentExecutor.addExecutor(childExecutor, rule);
				}
			}
		}
	}
}