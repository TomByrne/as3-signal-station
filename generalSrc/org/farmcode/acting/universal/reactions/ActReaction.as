package org.farmcode.acting.universal.reactions
{
	import org.farmcode.ScopeDisplayObject;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.UniversalActManager;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;

	public class ActReaction extends ScopeDisplayObject implements IActReaction
	{
		
		public function get phases():Array{
			return _phases;
		}
		public function set phases(value:Array):void{
			_phases = value;
		}
		
		private var _phases:Array;
		protected var _universalRules:Array = new Array();
		protected var _universalRuleAddedAct:Act = new Act();
		protected var _universalRuleRemovedAct:Act = new Act();
		
		public function ActReaction(){
			addedChanged.addHandler(onAddedChanged);
		}
		private function onAddedChanged(from:ScopeDisplayObject):void{
			if(added){
				UniversalActManager.addReaction(this);
			}else{
				UniversalActManager.removeReaction(this);
			}
		}
		
		public function execute(from:UniversalActExecution, params:Array):void{
			// override me
		}
		
		public function get universalRules():Array{
			return _universalRules;
		}
		/**
		 * @inheritDoc
		 */
		public function get universalRuleAddedAct():IAct{
			return _universalRuleAddedAct;
		}
		/**
		 * @inheritDoc
		 */
		public function get universalRuleRemovedAct():IAct{
			return _universalRuleRemovedAct;
		}
		
		
		public function addUniversalRule(universalRule:IUniversalRule):void{
			if(_universalRules.indexOf(universalRule)==-1){
				_universalRules.push(universalRule);
				_universalRuleAddedAct.perform(this, universalRule);
			}
		}
		public function removeUniversalRule(universalRule:IUniversalRule):void{
			var index:int = _universalRules.indexOf(universalRule);
			if(index!=-1){
				_universalRules.splice(index,1);
				_universalRuleRemovedAct.perform(this,universalRule);
			}
		}
		public function removeAllUniversalRules():void{
			var oldRules:Array = _universalRules;
			_universalRules = [];
			for each(var rule:IUniversalRule in oldRules){
				_universalRuleRemovedAct.perform(this,rule);
			}
		}
	}
}