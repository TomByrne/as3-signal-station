package org.tbyrne.compose.concerns
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.ITrait;
	
	public class AbstractConcern implements IConcern
	{
		
		/**
		 * @inheritDoc
		 */
		public function get traitAdded():IAct{
			return (_traitAdded || (_traitAdded = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get traitRemoved():IAct{
			return (_traitRemoved || (_traitRemoved = new Act()));
		}
		
		protected var _traitRemoved:Act;
		protected var _traitAdded:Act;
		
		
		public function get interestedTraitType():Class{
			return _interestedTraitType;
		}
		public function get siblings():Boolean{
			return _siblings;
		}
		public function get descendants():Boolean{
			return _descendants;
		}
		public function get ascendants():Boolean{
			return _ascendants;
		}
		public function get acceptOwnerTrait():Boolean{
			return _acceptOwnerTrait;
		}
		
		
		public function get ownerTrait():ITrait{
			return _ownerTrait;
		}
		public function set ownerTrait(value:ITrait):void{
			_ownerTrait = value;
		}
		
		private var _ownerTrait:ITrait;
		
		protected var _interestedTraitType:Class;
		protected var _descendants:Boolean;
		protected var _siblings:Boolean;
		protected var _ascendants:Boolean;
		protected var _acceptOwnerTrait:Boolean;
		
		protected var _addedTraits:Dictionary;
		
		public function AbstractConcern(siblings:Boolean, descendants:Boolean, ascendants:Boolean, interestedTraitType:Class){
			_interestedTraitType = interestedTraitType;
			_siblings = siblings;
			_descendants = descendants;
			_ascendants = ascendants;
			_addedTraits = new Dictionary(true);
		}
		
		
		
		public function concernAdded(trait:ITrait):void{
			// override me
		}
		
		public function concernRemoved(trait:ITrait):void{
			if(_addedTraits[trait]){
				delete _addedTraits[trait];
				if(_traitRemoved)_traitRemoved.perform(this,trait);
			}
		}
		
		
		protected function doAddTrait(trait:ITrait):void{
			_addedTraits[trait] = true;
			if(_traitAdded)_traitAdded.perform(this,trait);
		}
		protected function itemMatchesAll(item:ComposeItem, traitTypes:Vector.<Class>):Boolean{
			for each(var traitType:Class in traitTypes){
				if(!item.getTrait(traitType)){
					return false;
				}
			}
			return true;
		}
		protected function itemMatchesAny(item:ComposeItem, traitTypes:Vector.<Class>):Boolean{
			for each(var traitType:Class in traitTypes){
				if(item.getTrait(traitType)){
					return true;
				}
			}
			return false;
		}
		public function shouldDescend(item:ComposeItem):Boolean{
			// override me
			return true;
		}
	}
}