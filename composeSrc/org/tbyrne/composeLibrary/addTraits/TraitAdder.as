package org.tbyrne.composeLibrary.addTraits
{
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.factories.IInstanceFactory;
	
	public class TraitAdder extends AbstractTrait
	{
		public function get concernedTraitType():Class{
			return _concernedTraitType;
		}
		public function set concernedTraitType(value:Class):void{
			if(_concernedTraitType!=value){
				if(_concernedTraitType!=null){
					removeConcern(_concern);
				}
				_concernedTraitType = value;
				if(_concernedTraitType!=null){
					if(!_concern){
						_concern = new Concern(false,true,false);
					}
					_concern.interestedTraitType = value;
					addConcern(_concern);
				}
			}
		}
		
		public function get traitFactory():IInstanceFactory{
			return _traitFactory;
		}
		public function set traitFactory(value:IInstanceFactory):void{
			if(_traitFactory!=value){
				_traitFactory = value;
			}
		}
		
		private var _traitFactory:IInstanceFactory;
		private var _concern:Concern;
		private var _concernedTraitType:Class;
		
		
		public function TraitAdder(concernedTraitType:Class=null, traitFactory:IInstanceFactory=null){
			super();
			this.concernedTraitType = concernedTraitType;
			this.traitFactory = traitFactory;
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			
			if(trait is _concernedTraitType){
				_traitFactory.initialiseInstance(trait.item);
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			
			if(trait is _concernedTraitType){
				_traitFactory.deinitialiseInstance(trait.item);
			}
		}
	}
}