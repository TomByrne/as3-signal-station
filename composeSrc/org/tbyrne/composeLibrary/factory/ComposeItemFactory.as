package org.tbyrne.composeLibrary.factory
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.factories.IInstanceFactory;

	public class ComposeItemFactory implements IInstanceFactory
	{
		
		public function get useGroup():Boolean{
			return _useGroup;
		}
		public function set useGroup(value:Boolean):void{
			if(_useGroup!=value){
				_useGroup = value;
			}
		}
		
		private var _useGroup:Boolean;
		private var _traitTypes:Vector.<Class> = new Vector.<Class>();
		private var _traitFactories:Vector.<IInstanceFactory> = new Vector.<IInstanceFactory>();
		
		
		public function ComposeItemFactory(useGroup:Boolean=false, traitTypes:*=null){
			this.useGroup = useGroup;
			if(traitTypes)addTraitTypes(traitTypes);
		}
		
		
		public function addTraitTypes(traitTypes:*):void{
			for each(var traitType:Class in traitTypes){
				addTraitType(traitType)
			}
		}
		public function removeTraitTypes(traitTypes:*):void{
			for each(var traitType:Class in traitTypes){
				removeTraitType(traitType);
			}
		}
		public function addTraitType(traitType:Class):void{
			if(_traitTypes.indexOf(traitType)==-1){
				_traitTypes.push(traitType);
			}
		}
		public function removeTraitType(traitType:Class):void{
			var index:int = _traitTypes.indexOf(traitType);
			if(index!=-1){
				_traitTypes.splice(index,1);
			}
		}
		
		
		
		public function addTraitFactories(traitFactories:*):void{
			for each(var traitFactory:IInstanceFactory in traitFactories){
				addTraitFactory(traitFactory)
			}
		}
		public function removeTraitFactories(traitFactories:*):void{
			for each(var traitFactory:IInstanceFactory in traitFactories){
				removeTraitFactory(traitFactory);
			}
		}
		public function addTraitFactory(traitFactory:IInstanceFactory):void{
			if(_traitFactories.indexOf(traitFactory)==-1){
				_traitFactories.push(traitFactory);
			}
		}
		public function removeTraitFactory(traitFactory:IInstanceFactory):void{
			var index:int = _traitFactories.indexOf(traitFactory);
			if(index!=-1){
				_traitFactories.splice(index,1);
			}
		}
		
		
		
		
		public function createInstance():*{
			var instance:ComposeItem;
			if(_useGroup){
				instance = new ComposeGroup();
			}else{
				instance = new ComposeItem();
			}
			initialiseInstance(instance);
		}
		public function initialiseInstance(object:*):void{
			var trait:ITrait;
			
			var instance:ComposeItem = (object as ComposeItem);
			for each(var traitType:Class in _traitTypes){
				trait = new traitType();
				instance.addTrait(trait);
			}
			for each(var traitFactory:IInstanceFactory in _traitFactories){
				trait = traitFactory.createInstance();
				instance.addTrait(trait);
			}
		}
		
		
		
		public function returnInstance(object:*):void{
			
		}
		public function deinitialiseInstance(object:*):void{
			
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function matchesType(object:*):Boolean{
			if(_useGroup){
				return object is ComposeGroup;
			}else{
				return object is ComposeItem;
			}
		}
	}
}