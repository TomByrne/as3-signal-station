package org.farmcode.acting.universal
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.reactions.IActReaction;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	
	use namespace ActingNamspace;

	/*
	 * TODO: fix issues arising when one IActReaction has two rules that match the same IUniversalAct
	 */
	public class UniversalActManager
	{
		
		private static var managers:Dictionary = new Dictionary();
		private static var actMap:Dictionary = new Dictionary();
		private static var reactionMap:Dictionary = new Dictionary();
		/*
		mapped act > executor, this is kept static so that when acts get moved between managers
		their executors can be accessed via the new manager.
		*/		
		private static var executors:Dictionary = new Dictionary();
		
		public static function addManager(scopeDisplay:IDisplayAsset=null):void{
			if(managers[scopeDisplay]){
				throw new Error("Manager already added");
			}else{
				var parent:UniversalActManager = findManagerFor(scopeDisplay,false);
				var manager:UniversalActManager = new UniversalActManager();
				managers[scopeDisplay] = manager;
				if(parent){
					for(var i:* in parent.acts){
						var act:IUniversalAct = (i as IUniversalAct);
						if(findManagerFor(act.scope,false)==manager){
							parent.removeAct(act);
							manager.addAct(act);
							actMap[act] = manager;
						}
					}
					for(i in parent.reactions){
						var reaction:IActReaction = (i as IActReaction);
						if(findManagerFor(reaction.asset,false)==manager){
							parent.removeReaction(reaction);
							manager.addReaction(reaction);
							reactionMap[reaction] = manager;
						}
					}
				}
			}
		}
		public static function removeManager(scopeDisplay:IDisplayAsset):void{
			if(scopeDisplay){
				var subject:IDisplayAsset = scopeDisplay;
				while(subject){
					var manager:UniversalActManager = managers[subject];
					if(manager){
						delete managers[subject];
						
						var parent:UniversalActManager = findManagerFor(scopeDisplay,true);
						for(var i:* in manager.acts){
							var act:IUniversalAct = (i as IUniversalAct);
							manager.removeAct(act);
							parent.addAct(act);
							actMap[act] = parent;
						}
						for(i in manager.reactions){
							var reaction:IActReaction = (i as IActReaction);
							manager.removeReaction(reaction);
							parent.addReaction(reaction);
							reactionMap[reaction] = parent;
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
				var executor:UniversalActExecutor = executors[act];
				if(!executor){
					executor = UniversalActExecutor.getNew();
					executors[act] = executor;
					executor.act = act;
				}else{
					executor.executionsCompleted.removeHandler(onExecutionsComplete);
				}
				
				var manager:UniversalActManager = findManagerFor(act.scope,true);
				manager.addAct(act);
				act.scopeChanged.addHandler(onActScopeDisplayChange);
				actMap[act] = manager;
			}else{
				throw new Error("act already added");
			}
		}
		public static function removeAct(act:IUniversalAct):void{
			var manager:UniversalActManager = actMap[act];
			if(manager){
				var executor:UniversalActExecutor = executors[act];
				var doRemove:Boolean = (executor.executionCount==0);
				if(!doRemove){
					executor.executionsFrozen = true;
					executor.executionsCompleted.addTempHandler(onExecutionsComplete);
				}
				
				manager.removeAct(act);
				act.scopeChanged.removeHandler(onActScopeDisplayChange);
				delete actMap[act];
				
				if(doRemove){
					executor.release();
					delete executors[act];
				}
			}else{
				throw new Error("act has not been added");
			}
		}
		protected static function onExecutionsComplete(executor:UniversalActExecutor):void{
			executor.executionsFrozen = false;
			delete executors[executor.act];
			executor.release();
		}
		public static function addReaction(reaction:IActReaction):void{
			if(!reactionMap[reaction]){
				var manager:UniversalActManager = findManagerFor(reaction.asset,true);
				manager.addReaction(reaction);
				reaction.assetChanged.addHandler(onReactionScopeDisplayChange);
				reactionMap[reaction] = manager;
			}else{
				throw new Error("reaction already added");
			}
		}
		public static function removeReaction(reaction:IActReaction):void{
			var manager:UniversalActManager = reactionMap[reaction];
			if(manager){
				manager.removeReaction(reaction);
				reaction.assetChanged.removeHandler(onReactionScopeDisplayChange);
				delete reactionMap[reaction];
			}else{
				throw new Error("reaction has not been added");
			}
		}
		private static function findManagerFor(scopeDisplay:IDisplayAsset, createRoot:Boolean):UniversalActManager{
			var manager:UniversalActManager;
			if(scopeDisplay){
				var subject:IDisplayAsset = scopeDisplay;
				while(subject){
					manager = managers[subject];
					if(manager)return manager;
					subject = subject.parent;
				}
			}
			if(createRoot && !managers[null]){
				manager = new UniversalActManager();
				managers[null] = manager;
			}
			return managers[null];
		}
		private static function onActScopeDisplayChange(act:IUniversalAct, oldAsset:IDisplayAsset):void{
			var oldManager:UniversalActManager = actMap[act];
			var newManager:UniversalActManager = findManagerFor(act.scope, true);
			if(oldManager!=newManager){
				oldManager.removeAct(act);
				newManager.addAct(act);
				actMap[act] = newManager;
			}
		}
		private static function onReactionScopeDisplayChange(reaction:IActReaction, oldAsset:IDisplayAsset):void{
			var oldManager:UniversalActManager = reactionMap[reaction];
			var newManager:UniversalActManager = findManagerFor(reaction.asset, true);
			if(oldManager!=newManager){
				oldManager.removeReaction(reaction);
				newManager.addReaction(reaction);
				reactionMap[reaction] = newManager;
			}
		}
		
		
		
		
		
		
		
		
		
		public function UniversalActManager(){
		}
		internal var acts:Dictionary = new Dictionary();
		internal var reactions:Dictionary = new Dictionary();
		
		public function addAct(act:IUniversalAct):void{
			Config::DEBUG{
				if(acts[act]){
					throw new Error("This Act has already been added to this UniversalActManager");
				}
			}
			var executor:UniversalActExecutor = executors[act];
			for(var i:* in reactions){
				var reaction:IActReaction = (i as IActReaction);
				for each(var rule:IUniversalRule in reaction.universalRules){
					if(tryAddReaction(executor, reaction, rule)){
						break;
					}
				}
			}
			acts[act] = true;
		}
		public function removeAct(act:IUniversalAct):void{
			Config::DEBUG{
				if(!acts[act]){
					throw new Error("This act doesn't exist within this UniversalActManager");
				}
			}
			var executor:UniversalActExecutor = executors[act];
			/*for(var i:* in reactions){
				var reaction:IActReaction = (i as IActReaction);
				executor.removeReaction(reaction);
			}*/
			executor.removeAllReactions();
			delete acts[act];
		}
		public function addReaction(reaction:IActReaction):void{
			if(!reactions[reaction]){
				for(var i:* in acts){
					var executor:UniversalActExecutor = executors[i];
					for each(var rule:IUniversalRule in reaction.universalRules){
						if(tryAddReaction(executor, reaction, rule)){
							break;
						}
					}
				}
				reactions[reaction] = true;
				reaction.universalRuleAddedAct.addHandler(onRuleAdded);
				reaction.universalRuleRemovedAct.addHandler(onRuleRemoved);
			}else{
				throw new Error("This IActReaction has already been added to this UniversalActManager");
			}
		}
		public function removeReaction(reaction:IActReaction):void{
			if(reactions[reaction]){
				for(var i:* in acts){
					var executor:UniversalActExecutor = executors[i];
					executor.removeReaction(reaction);
				}
				delete reactions[reaction];
				reaction.universalRuleAddedAct.removeHandler(onRuleAdded);
				reaction.universalRuleRemovedAct.removeHandler(onRuleRemoved);
			}else{
				throw new Error("This IActReaction has not been added to this UniversalActManager");
			}
		}
		protected function onRuleAdded(reaction:IActReaction, rule:IUniversalRule):void{
			for(var i:* in acts){
				var executor:UniversalActExecutor = executors[i];
				tryAddReaction(executor, reaction, rule);
			}
		}
		protected function onRuleRemoved(reaction:IActReaction, rule:IUniversalRule):void{
			var childExecutor:UniversalActExecutor = executors[reaction];
			for(var i:* in acts){
				var executor:UniversalActExecutor = executors[i];
				executor.removeReaction(reaction);
			}
		}
		protected function tryAddReaction(executer:UniversalActExecutor, reaction:IActReaction, rule:IUniversalRule):Boolean{
			if(rule.shouldReact(executer.act)){
				executer.addReaction(reaction, rule);
				return true;
			}else{
				return false;
			}
		}
	}
}