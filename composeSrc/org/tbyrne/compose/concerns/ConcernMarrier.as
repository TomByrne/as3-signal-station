package org.tbyrne.compose.concerns
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.traits.TraitCollection;

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
		
		public function addConcern(traitConcern:IConcern):void{
			CONFIG::debug{
				if(!traitConcern)Log.error("ConcernMarrier.addConcern must have concern supplied");
				if(_traitConcerns.containsItem(traitConcern))Log.error("ComposeGroup.addConcern already contains concern.");
			}
			
			_traitConcerns.add(traitConcern);
			
			for each(var trait:ITrait in _traits.traits.list){
				compareTrait(trait, traitConcern);
			}
			//testCheck();
		}
		public function removeConcern(traitConcern:IConcern):void{
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
			//testCheck();
		}
		
		/*private function testCheck():void
		{
			for each(var traitLookup:IndexedList in _traitLookup){
				if(traitLookup.list.length>_traitConcerns.list.length){
					Log.error("Holy Funk");
				}
			}
			for each(var concernLookup:IndexedList in _concernLookup){
				if(concernLookup.list.length>_traits.traits.list.length){
					Log.error("Holy Funk");
				}
			}
		}*/
		
		protected function onTraitAdded(from:TraitCollection, trait:ITrait):void{
			for each(var traitConcern:IConcern in _traitConcerns.list){
				compareTrait(trait, traitConcern);
			}
			//testCheck();
		}
		
		protected function onTraitRemoved(from:TraitCollection, trait:ITrait):void{
			var concerns:IndexedList = _traitLookup[trait];
			if(concerns){
				for each(var traitConcern:IConcern in concerns.list){
					traitConcern.concernRemoved(trait);
					
					var concernLookup:IndexedList = _concernLookup[traitConcern];
					concernLookup.remove(trait);
				}
				concerns.clear();
				delete _traitLookup[trait];
			}
			//testCheck();
		}
		
		
		protected function compareTrait(trait:ITrait, traitConcern:IConcern):void{
			if((trait is traitConcern.interestedTraitType) && (trait!=traitConcern.ownerTrait || traitConcern.acceptOwnerTrait)){
				
				// add to concern lookup
				var concernList:IndexedList = _concernLookup[traitConcern];
				if(!concernList){
					concernList = new IndexedList();
					_concernLookup[traitConcern] = concernList;
				}
				concernList.add(trait);
				
				// add to trait lookup
				var traitList:IndexedList = _traitLookup[trait];
				if(!traitList){
					traitList = new IndexedList();
					_traitLookup[trait] = traitList;
				}
				traitList.add(traitConcern);
				
				traitConcern.concernAdded(trait);
			}
			//testCheck();
		}
	}
}