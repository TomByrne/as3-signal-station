package org.tbyrne.acting.universal.reactions
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.UniversalActManager;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.ScopedObject;

	public class ActReaction extends ScopedObject implements IActReaction
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
		protected var _univAdded:Boolean;
		
		public function ActReaction(){
			addedChanged.addHandler(onAddedChanged);
			assetChanged.addHandler(onDisplayChanged);
		}
		private function onAddedChanged(from:ScopedObject):void{
			if(added){
				_univAdded = true;
				UniversalActManager.addReaction(this);
			}else{
				_univAdded = false;
				UniversalActManager.removeReaction(this);
			}
		}
		private function onDisplayChanged(from:ScopedObject, oldAsset:IDisplayAsset):void{
			if(_univAdded){
				UniversalActManager.removeReaction(this);
				UniversalActManager.addReaction(this);
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