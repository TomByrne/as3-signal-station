package org.farmcode.display.assets
{
	import flash.utils.Dictionary;
	
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.states.IStateDef;
	
	public class AbstractAsset implements IAsset
	{
		public function get factory():IAssetFactory{
			return _factory;
		}
		public function set factory(value:IAssetFactory):void{
			_factory = value;
		}
		public function get useParentStateLists():Boolean{
			return _useParentStateLists;
		}
		public function set useParentStateLists(value:Boolean):void{
			if(_useParentStateLists!=value){
				_useParentStateLists = value;
				
				var stateList:Array;
				if(value){
					for each(stateList in _parentStateLists){
						_addStateList(stateList);
					}
				}else{
					for each(stateList in _parentStateLists){
						_removeStateList(stateList);
					}
				}
			}
		}
		
		protected var _useParentStateLists:Boolean = true;
		protected var _factory:IAssetFactory;
		protected var _stateLists:Array = [];
		protected var _parentStateLists:Array = [];
		protected var _availableStates:Array = [];
		protected var _appliedStates:Array = [];
		// state:IStateDef -> stateOptionName:String
		protected var _stateSelMap:Dictionary = new Dictionary();
		
		
		public function AbstractAsset(factory:IAssetFactory){
			this.factory = factory;
		}
		/**
		 * This is to be called by the IAssetFactory only (when
		 * it's destroyAsset is called.
		 */
		public function reset():void{
			// override me
		}
		
		
		final public function addStateList(stateList:Array, fromParentAsset:Boolean):void{
			if(fromParentAsset){
				_parentStateLists.push(stateList);
			}
			if(_useParentStateLists || !fromParentAsset){
				_addStateList(stateList);
			}
		}
		protected function _addStateList(stateList:Array):void{
			CONFIG::debug{
				if(_stateLists.indexOf(stateList)!=-1){
					throw new Error("This state list has already been added");
				}
			}
			_stateLists.push(stateList);
			
			findAvailableStates();
		}
		final public function removeStateList(stateList:Array):void{
			var index:int = _parentStateLists.indexOf(stateList);
			if(index!=-1)_parentStateLists.splice(index,1);
			
			if(_useParentStateLists || index==-1){
				_removeStateList(stateList);
			}
		}
		protected function _removeStateList(stateList:Array):void{
			var index:int = _stateLists.indexOf(stateList);
			_stateLists.splice(index,1);
			
			findAvailableStates();
		}
		public function conformsToType(type:Class):Boolean{
			return (this is type);
		}
		
		
		
		protected function findAvailableStates():void{
			var state:IStateDef;
			if(_availableStates.length){
				for each(state in _availableStates){
					state.selectionChanged.removeHandler(onStateSelChanged);
				}
				_availableStates = [];
			}
			for each(var stateList:Array in _stateLists){
				// traverse backwards to give later lists priority
				for(var i:int=stateList.length-1; i>=0; --i){
					state = stateList[i];
					if(isStateAvailable(state,_availableStates)){
						_availableStates.unshift(state);
						state.selectionChanged.addHandler(onStateSelChanged);
					}
				}
			}
			applyAvailableStates();
		}
		protected function applyAvailableStates():void{
			var newStates:Array = [];
			var newMap:Dictionary = new Dictionary();
			var state:IStateDef;
			var selName:String;
			
			for each(state in _availableStates){
				if(state.selection!=-1){
					selName = state.options[state.selection];
					if(isStateNameAvailable(selName)){
						newStates.push(state);
						newMap[state] = true;
					}
				}
			}
			unapplyOldState(newMap, newStates);
			var appliedStates:Array = [];
			for each(state in newStates){
				selName = state.options[state.selection];
				_stateSelMap[state] = selName;
				var time:Number = applyState(state,selName,appliedStates);
				if(state.stateChangeDuration<time){
					state.stateChangeDuration = time;
				}
				appliedStates.push(state);
			}
			_appliedStates = appliedStates;
		}
		protected function unapplyOldState(newMap:Dictionary, newList:Array):void{
			for each(var state:IStateDef in _appliedStates){
				if(!newMap[state]){
					var selName:String = _stateSelMap[state];
					var time:Number = unapplyState(state,selName,newList);
					if(state.stateChangeDuration<time){
						state.stateChangeDuration = time;
					}
				}
			}
		}
		protected function onStateSelChanged(state:IStateDef):void{
			applyAvailableStates();
		}
		
		
		
		
		
		protected function isStateAvailable(state:IStateDef, otherAvailable:Array):Boolean {
			for each(var stateName:String in state.options){
				if(isStateNameAvailable(stateName))return true;
			}
			return false;
		}
		protected function isStateNameAvailable(state:String):Boolean {
			return true;
		}
		protected function unapplyState(state:IStateDef, stateName:String, nextStates:Array):Number {
			return 0;
		}
		protected function applyState(state:IStateDef, stateName:String, appliedStates:Array):Number {
			return 0;
		}
		
	}
}