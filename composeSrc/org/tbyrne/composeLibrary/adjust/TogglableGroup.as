package org.tbyrne.composeLibrary.adjust
{
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.adjust.ITogglableTrait;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.collections.IndexedList;
	
	public class TogglableGroup extends AbstractTrait
	{
		
		public function get togglableGroupId():String{
			return _togglableGroupId;
		}
		public function set togglableGroupId(value:String):void{
			_togglableGroupId = value;
		}
		
		private var _togglableGroupId:String;
		private var _traits:IndexedList;
		
		public function TogglableGroup(togglableGroupId:String=null)
		{
			super();
			
			this.togglableGroupId = togglableGroupId;
			
			
			var concern:Concern = new Concern(true,true,ITogglableTrait);
			concern.stopDescendingAt = Vector.<Class>([TogglableGroup]);
			addConcern(concern);
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var castTrait:ITogglableTrait = (trait as ITogglableTrait);
			
			if(castTrait.togglableGroup==togglableGroupId){
				_traits.push(castTrait);
				
				castTrait.isToggledChanged.addHandler(onIsToggledChanged);
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var castTrait:ITogglableTrait = (trait as ITogglableTrait);
			
			if(_traits.containsItem(castTrait)){
				_traits.remove(castTrait);
				castTrait.isToggledChanged.addHandler(onIsToggledChanged);
			}
		}
		
		
		private function onIsToggledChanged():void{
			// TODO Auto Generated method stub
			
		}
	}
}