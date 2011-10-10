package org.tbyrne.tbyrne.compose.concerns
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.tbyrne.compose.traits.TraitCollection;

	public class ConcernMarrier
	{
		
		public function get traits():TraitCollection{
			return _traits;
		}
		public function set traits(value:TraitCollection):void{
			if(_traits!=value){
				if(_traits){
					_traits.traitAdded.removeHandler(onTraitAdded);
					_traits.traitRemoved.removeHandler(onTraitRemoved);
				}
				_traits = value;
				if(_traits){
					_traits.traitAdded.addHandler(onTraitAdded);
					_traits.traitRemoved.addHandler(onTraitRemoved);
				}
			}
		}
		public function get traitConcerns():IndexedList{
			return _traitConcerns;
		}
		
		private var _traits:TraitCollection;
		private var _traitConcerns:IndexedList = new IndexedList();
		
		// mapped concern > [traits]
		private var _concernLookup:Dictionary = new Dictionary();
		
		// mapped trait > [concerns]
		private var _traitLookup:Dictionary = new Dictionary();
		
		public function ConcernMarrier(traits:TraitCollection){
			this.traits = traits;
		}
		
		public function addConcern(traitConcern:ITraitConcern):void{
			CONFIG::debug{
				if(!traitConcern)Log.error("ConcernMarrier.addConcern must have concern supplied");
				if(_traitConcerns.containsItem(traitConcern))Log.error("ComposeGroup.addConcern already contains concern.");
			}
			
			_traitConcerns.push(traitConcern);
			
			for each(var trait:ITrait in _traits.traits.list){
				compareTrait(trait, traitConcern);
			}
		}
		public function removeConcern(traitConcern:ITraitConcern):void{
			CONFIG::debug{
				if(!traitConcern)Log.error("ConcernMarrier.removeConcern must have concern supplied");
				if(!_traitConcerns.containsItem(traitConcern))Log.error("ComposeGroup.removeConcern doesn't contain concern.");
			}
			
			_traitConcerns.remove(traitConcern);
			
			var traits:IndexedList = _concernLookup[traitConcern];
			if(traits){
				for each(var trait:ITrait in traits.list){
					traitConcern.concernRemoved(trait);
					
					var traitLookup:IndexedList = _traitLookup[trait];
					traitLookup.remove(traitConcern);
				}
				traits.clear();
				delete _concernLookup[traitConcern];
			}
		}
		
		protected function onTraitAdded(from:TraitCollection, trait:ITrait):void{
			for each(var traitConcern:ITraitConcern in _traitConcerns.list){
				compareTrait(trait, traitConcern);
			}
		}
		
		protected function onTraitRemoved(from:TraitCollection, trait:ITrait):void{
			var concerns:IndexedList = _traitLookup[trait];
			if(concerns){
				for each(var traitConcern:ITraitConcern in concerns.list){
					traitConcern.concernRemoved(trait);
					
					var concernLookup:IndexedList = _concernLookup[traitConcern];
					concernLookup.remove(trait);
				}
				concerns.clear();
				delete _traitLookup[trait];
			}
		}
		
		
		protected function compareTrait(trait:ITrait, traitConcern:ITraitConcern):void{
			if(trait is traitConcern.interestedTraitType){
				
				// add to concern lookup
				var concernList:IndexedList = _concernLookup[traitConcern];
				if(!concernList){
					concernList = new IndexedList();
					_concernLookup[traitConcern] = concernList;
				}
				concernList.push(trait);
				
				// add to trait lookup
				var traitList:IndexedList = _traitLookup[trait];
				if(!traitList){
					traitList = new IndexedList();
					_traitLookup[trait] = traitList;
				}
				traitList.push(trait);
				
				traitConcern.concernAdded(trait);
			}
		}
	}
}