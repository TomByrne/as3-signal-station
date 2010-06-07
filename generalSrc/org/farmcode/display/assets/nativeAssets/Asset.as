package org.farmcode.display.assets.nativeAssets
{
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.states.IStateDef;
	
	public class Asset implements IAsset
	{
		protected var _state:String;
		protected var _stateLists:Array = [];
		protected var _availableStates:Array = [];
		protected var _appliedStates:Array = [];
		
		public function Asset(){
		}
		public function createAsset(name:String, type:Class):*{
			return NativeAssetFactory.getNewByType(type);
		}
		public function destroyAsset(asset:IAsset):void{
			var cast:Asset = (asset as Asset);
			cast.release();
		}
		public function release():void {
			NativeAssetFactory.returnAsset(this);
		}
		
		
		public function addStateList(stateList:Array):void{
			_stateLists.push(stateList);
			var change:Boolean;
			for each(var state:IStateDef in stateList){
				if(isStateAvailable(state,_availableStates)){
					_availableStates.push(state);
					state.selectionChanged.addHandler(onStateSelChanged);
					change = true;
				}
			}
			if(change)applyAvailableStates();
		}
		public function removeStateList(stateList:Array):void{
			var index:int = _stateLists.indexOf(stateList);
			_stateLists.splice(index,1);
			
			var change:Boolean;
			for each(var state:IStateDef in stateList){
				index = _availableStates.indexOf(state);
				if(index!=-1){
					_availableStates.splice(index,1);
					change = true;
				}
			}
			if(change)applyAvailableStates();
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
				for each(state in stateList){
					if(isStateAvailable(state,_availableStates)){
						_availableStates.push(state);
						state.selectionChanged.addHandler(onStateSelChanged);
					}
				}
			}
			applyAvailableStates();
		}
		protected function applyAvailableStates():void{
			if(_appliedStates.length)_appliedStates = [];
			for each(var state:IStateDef in _availableStates){
				if(state.selection!=-1){
					var selName:String = state.options[state.selection];
					if(isStateNameAvailable(selName)){
						var time:Number = applyState(state,selName,_appliedStates);
						if(state.stateChangeDuration<time){
							state.stateChangeDuration = time;
						}
						_appliedStates.push(state);
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
		protected function applyState(state:IStateDef, stateName:String, appliedStates:Array):Number {
			return 0;
		}
		
	}
}