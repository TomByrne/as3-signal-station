package org.tbyrne.tbyrne.compose.concerns
{
	import org.tbyrne.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	
	public class TraitConcern extends AbstractTraitConcern
	{
		
		public function get unlessHasTraits():Vector.<Class>{
			return _unlessHasTraits;
		}
		public function set unlessHasTraits(value:Vector.<Class>):void{
			_unlessHasTraits = value;
		}
		
		public function get additionalTraits():Vector.<Class>{
			return _additionalTraits;
		}
		public function set additionalTraits(value:Vector.<Class>):void{
			_additionalTraits = value;
		}
		
		public function get stopDescendingAt():Vector.<Class>{
			return _stopDescendingAt;
		}
		public function set stopDescendingAt(value:Vector.<Class>):void{
			_stopDescendingAt = value;
		}
		
		private var _stopDescendingAt:Vector.<Class>;
		private var _additionalTraits:Vector.<Class>;
		private var _unlessHasTraits:Vector.<Class>;
		
		
		public function TraitConcern(siblings:Boolean, descendants:Boolean, interestedTraitType:Class, stopDescendingAt:Array=null){
			super(siblings, descendants, interestedTraitType);
			if(stopDescendingAt!=null)this.stopDescendingAt = Vector.<Class>(stopDescendingAt);
		}
		
		
		override public function concernAdded(trait:ITrait):void{
			var item:ComposeItem = trait.item;
			
			if(!_additionalTraits || itemMatchesAll(item,_additionalTraits)){
				if(!_unlessHasTraits || !itemMatchesAll(item,_unlessHasTraits)){
					doAddTrait(trait);
				}
			}
		}
		override public function shouldDescend(item:ComposeGroup):Boolean{
			if(_stopDescendingAt){
				return !itemMatchesAll(item,_stopDescendingAt);
			}else{
				return true;
			}
		}
	}
}