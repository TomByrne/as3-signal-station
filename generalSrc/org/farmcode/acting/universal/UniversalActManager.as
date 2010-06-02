package org.farmcode.acting.universal
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IAsynchronousAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	import org.farmcode.acting.universal.reactions.IActReaction;
	
	use namespace ActingNamspace;

	/**
	 * TODO: fix issues arising when one IActReaction has two rules that match the same IUniversalAct
	 */
	public class UniversalActManager
	{
		
		private static var managers:Dictionary = new Dictionary();
		private static var actMap:Dictionary = new Dictionary();
		private static var reactionMap:Dictionary = new Dictionary();
		
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
				act.scopeDisplayChanged.addHandler(onActScopeDisplayChange);
				actMap[act] = manager;
			}else{
				throw new Error("act already added");
			}
		}
		public static function removeAct(act:IUniversalAct):void{
			var manager:UniversalActManager = actMap[act];
			if(manager){
				manager.removeAct(act);
				act.scopeDisplayChanged.removeHandler(onActScopeDisplayChange);
				delete actMap[act];
			}else{
				throw new Error("act has not been added");
			}
		}
		public static function addReaction(reaction:IActReaction):void{
			if(!reactionMap[reaction]){
				var manager:UniversalActManager = findManagerFor(reaction.scopeDisplay,true);
				manager.addReaction(reaction);
				reaction.scopeDisplayChanged.addHandler(onReactionScopeDisplayChange);
				reactionMap[reaction] = manager;
			}else{
				throw new Error("reaction already added");
			}
		}
		public static function removeReaction(reaction:IActReaction):void{
			var manager:UniversalActManager = reactionMap[reaction];
			if(manager){
				manager.removeReaction(reaction);
				reaction.scopeDisplayChanged.removeHandler(onReactionScopeDisplayChange);
				delete reactionMap[reaction];
			}else{
				throw new Error("reaction has not been added");
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
		private static function onActScopeDisplayChange(act:IUniversalAct):void{
			var oldManager:UniversalActManager = actMap[act];
			var newManager:UniversalActManager = findManagerFor(act.scopeDisplay, true);
			if(oldManager!=newManager){
				oldManager.removeAct(act);
				newManager.addAct(act);
				actMap[act] = newManager;
			}
		}
		private static function onReactionScopeDisplayChange(reaction:IActReaction):void{
			var oldManager:UniversalActManager = reactionMap[reaction];
			var newManager:UniversalActManager = findManagerFor(reaction.scopeDisplay, true);
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
		internal var pendingRemoveActs:Dictionary = new Dictionary();
		
		public function addAct(act:IUniversalAct):void{
			var actExecutor:UniversalActExecutor = acts[act];
			if(!actExecutor){
				var executor:UniversalActExecutor = UniversalActExecutor.getNew();
				executor.act = act;
				for(var i:* in reactions){
					var reaction:IActReaction = (i as IActReaction);
					for each(var rule:IUniversalRule in reaction.universalRules){
						tryAddReaction(executor, reaction, rule);
					}
				}
				acts[act] = executor;
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
			actExecutor.release();
			delete acts[act];
		}
		public function addReaction(reaction:IActReaction):void{
			if(!reactions[reaction]){
				for each(var executor:UniversalActExecutor in acts){
					for each(var rule:IUniversalRule in reaction.universalRules){
						tryAddReaction(executor, reaction, rule);
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
				for each(var executor:UniversalActExecutor in acts){
					executor.removeReaction(reaction);
				}
				delete reactions[reaction];
				reaction.universalRuleAddedAct.removeHandler(onRuleAdded);
				reaction.universalRuleRemovedAct.removeHandler(onRuleRemoved);
			}else{
				throw new Error("This IActReaction has not been added to this UniversalActManager");
			}
		}
		protected function onExecutorComplete(actExecutor:UniversalActExecutor):void{
			_removeAct(actExecutor.act,actExecutor);
		}
		protected function onRuleAdded(reaction:IActReaction, rule:IUniversalRule):void{
			for each(var executor:UniversalActExecutor in acts){
				tryAddReaction(executor, reaction, rule);
			}
		}
		protected function onRuleRemoved(reaction:IActReaction, rule:IUniversalRule):void{
			var childExecutor:UniversalActExecutor = acts[reaction];
			for each(var executor:UniversalActExecutor in acts){
				executor.removeReaction(reaction);
			}
		}
		protected function tryAddReaction(executer:UniversalActExecutor, reaction:IActReaction, rule:IUniversalRule):void{
			if(rule.shouldReact(executer.act)){
				executer.addReaction(reaction, rule);
			}
		}
	}
}