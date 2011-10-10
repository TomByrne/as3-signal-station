package org.tbyrne.tbyrne.compose.concerns
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.collections.IndexedList;

	public class ConcernComparer
	{
		public function get traits():IndexedList{
			return _traits;
		}
		public function get descendantTraits():IndexedList{
			return _descendantTraits;
		}
		
		// ITraitConcern > IndexedArray.<ITrait>
		private var _matched:Dictionary;
		private var _traitConcerns:IndexedList;
		private var _traits:IndexedList;
		private var _descendantTraits:IndexedList;
		
		public function ConcernComparer(){
			_traitConcerns = new IndexedList();
			_traits = new IndexedList();
			_descendantTraits = new IndexedList();
			_matched = new Dictionary();
		}
		
		public function addTraitConcern(traitConcern:ITraitConcern):void{
			CONFIG::debug{
				if(_traitConcerns.containsItem(traitConcern)){
					Log.trace("WARNING:: ITraitConcern already added to this ConcernComparer");
				}
			}
			_traitConcerns.push(traitConcern);
			
			var trait:ITrait;
			if(traitConcern.siblings){
				for each(trait in _traits){
					compareTrait(trait, traitConcern);
				}
			}
			if(traitConcern.descendants){
				for each(trait in _descendantTraits){
					compareTrait(trait, traitConcern);
				}
			}
		}
		
		public function removeTraitConcern(traitConcern:ITraitConcern):void{
			CONFIG::debug{
				if(!_traitConcerns.containsItem(traitConcern)){
					Log.trace("WARNING:: ITraitConcern already added to this ConcernComparer");
				}
			}
			_traitConcerns.remove(traitConcern);
			
			
			var traitList:IndexedList = _matched[traitConcern];
			if(traitList){
				for each(var trait:ITrait in traitList.list){
					traitConcern.concernRemoved(trait);
				}
				delete _matched[traitConcern];
			}
		}
		
		public function addTrait(trait:ITrait, isDescendant:Boolean):void{
			var list:IndexedList = (isDescendant?_descendantTraits:_traits);
			
			CONFIG::debug{
				if(list.containsItem(trait)){
					Log.trace("WARNING:: ITrait already added to this ConcernComparer");
				}
			}
			list.push(trait);
			
			for each(var traitConcern:ITraitConcern in _traitConcerns.list){
				if((!isDescendant && traitConcern.siblings) || (isDescendant && traitConcern.descendants)){
					compareTrait(trait,traitConcern);
				}
			}
		}
		public function removeTrait(trait:ITrait, isDescendant:Boolean):void{
			var list:IndexedList = (isDescendant?_descendantTraits:_traits);
			
			CONFIG::debug{
				if(!list.containsItem(trait)){
					Log.trace("WARNING:: ITrait already added to this ConcernComparer");
				}
			}
			list.remove(trait);
			
			for each(var traitConcern:ITraitConcern in _traitConcerns.list){
				var traitList:IndexedList = _matched[traitConcern];
				if(traitList && traitList.containsItem(trait)){
					traitConcern.concernRemoved(trait);
					traitList.remove(trait);
				}
			}
		}
		
		
		private function compareTrait(trait:ITrait, traitConcern:ITraitConcern):void{
			if(trait is traitConcern.interestedTraitType){
				var traitList:IndexedList = _matched[traitConcern];
				if(!traitList){
					traitList = new IndexedList();
					_matched[traitConcern] = traitList;
				}
				traitConcern.concernAdded(trait);
			}
		}
	}
}