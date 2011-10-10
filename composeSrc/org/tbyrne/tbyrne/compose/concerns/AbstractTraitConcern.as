package org.tbyrne.tbyrne.compose.concerns
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.tbyrne.compose.core.ComposeItem;
	
	public class AbstractTraitConcern implements ITraitConcern
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
		
		protected var _interestedTraitType:Class;
		protected var _descendants:Boolean;
		protected var _siblings:Boolean;
		
		protected var _addedTraits:Dictionary;
		
		public function AbstractTraitConcern(siblings:Boolean, descendants:Boolean, interestedTraitType:Class){
			_interestedTraitType = interestedTraitType;
			_siblings = siblings;
			_descendants = descendants;
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
		public function shouldDescend(item:ComposeGroup):Boolean{
			// override me
			return true;
		}
	}
}