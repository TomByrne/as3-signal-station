package org.farmcode.acting.acts
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.UniversalActManager;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	public class UniversalAct extends Act implements IUniversalAct
	{
		public function UniversalAct(){
			super();
			active = true;
		}
		
		protected var _active:Boolean;
		protected var _scopeDisplay:DisplayObject;
		protected var _scopeDisplayStage:Stage;
		protected var _scopeDisplayChangeAct:Act = new Act();
		protected var _universalRules:Array = new Array();
		protected var _universalRuleAddedAct:Act = new Act();
		protected var _universalRuleRemovedAct:Act = new Act();
		protected var _lastExecution:UniversalActExecution;
		protected var _added:Boolean;
		
		public function get scopeDisplay():DisplayObject{
			return _scopeDisplay;
		}
		public function set scopeDisplay(value:DisplayObject):void{
			if(_scopeDisplay!=value){
				if(_scopeDisplay){
					_scopeDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
					_scopeDisplay.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
				}
				_scopeDisplay = value;
				if(_scopeDisplay){
					_scopeDisplay.addEventListener(Event.ADDED_TO_STAGE, onAdded);
					_scopeDisplay.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
					_scopeDisplayStage = _scopeDisplay.stage;
				}else{
					_scopeDisplayStage = null;
				}
				_scopeDisplayChangeAct.perform(this);
				checkAdded();
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get scopeDisplayChangeAct():IAct{
			return _scopeDisplayChangeAct;
		}
		
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_active != value){
				_active = value;
				checkAdded();
			}
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
		public function temporaryPerform(scopeDisplay:DisplayObject, ... params):void{
			this.scopeDisplay = scopeDisplay;
			perform.apply(null,params);
			this.scopeDisplay = null;
		}
		public function universalPerform(execution:UniversalActExecution, ... params):void{
			_lastExecution = execution;
			perform.apply(null,params);
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
		
		protected function onAdded(e:Event):void{
			_scopeDisplayStage = _scopeDisplay.stage;
			checkAdded();
		}
		protected function onRemoved(e:Event):void{
			_scopeDisplayStage = null;
			checkAdded();
		}
		protected function checkAdded():void{
			var shouldAdd:Boolean = shouldAddToManager();
			if(shouldAdd){
				if(!_added){
					_added = true;
					UniversalActManager.addAct(this);
				}
			}else if(_added){
				_added = false;
				UniversalActManager.removeAct(this);
			}
		}
		protected function shouldAddToManager():Boolean{
			return _active && _scopeDisplay!=null && _scopeDisplayStage;
		}
	}
}