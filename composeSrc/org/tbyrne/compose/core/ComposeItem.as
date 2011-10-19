package org.tbyrne.compose.core
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.ComposeNamespace;
	import org.tbyrne.compose.concerns.ConcernMarrier;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.compose.traits.TraitCollection;
	
	use namespace ComposeNamespace;

	public class ComposeItem
	{
		
		
		public function get parentItem():ComposeGroup{
			return _parentItem;
		}
		public function set parentItem(value:ComposeGroup):void{
			if(_parentItem!=value){
				if(_parentItem){
					onParentRemove();
				}
				_parentItem = value;
				if(_parentItem){
					onParentAdd();
				}
			}
		}
		public function get root():ComposeRoot{
			return _root;
		}
		
		protected var _parentItem:ComposeGroup;
		protected var _root:ComposeRoot;
		protected var _traitCollection:TraitCollection;
		protected var _siblingMarrier:ConcernMarrier;
		protected var _parentMarrier:ConcernMarrier;
		
		public function ComposeItem(initTraits:Array=null){
			_traitCollection = new TraitCollection();
			_siblingMarrier = new ConcernMarrier(_traitCollection);
			_parentMarrier = new ConcernMarrier(_traitCollection);
			if(initTraits){
				for each(var trait:ITrait in initTraits){
					addTrait(trait);
				}
			}
		}
		ComposeNamespace function setRoot(root:ComposeRoot):void{
			_root = root;
		}
		public function getTrait(matchType:Class):*{
			return _traitCollection.getTrait(matchType);
		}
		public function getTraits(matchType:Class=null):Array{
			return _traitCollection.getTraits(matchType);
		}
		
		
		
		/**
		 * handler(composeItem:ComposeItem, trait:ITrait);
		 */
		public function callForTraits(func:Function, ifMatches:Class=null, params:Array=null):void{
			_traitCollection.callForTraits(func,ifMatches,this,params);
		}
		public function addTrait(trait:ITrait):void{
			_addTrait(trait);
		}
		public function addTraits(traits:Vector.<ITrait>):void{
			for each(var trait:ITrait in traits){
				_addTrait(trait);
			}
		}
		protected function _addTrait(trait:ITrait):void{
			CONFIG::debug{
				if(_root && _root!=this){
					Log.trace("WARNING:: ITrait being added while ComposeItem added to root");
				}
			}
			trait.item = this;
			_traitCollection.addTrait(trait);
			if(_parentItem)_parentItem.addChildTrait(trait);
			
			for each(var concern:ITraitConcern in trait.concerns){
				addTraitConcern(concern);
			}
		}
		
		public function removeTrait(trait:ITrait):void{
			_removeTrait(trait);
		}
		public function removeTraits(traits:Vector.<ITrait>):void{
			for each(var trait:ITrait in traits){
				_removeTrait(trait);
			}
		}
		public function removeAllTraits():void{
			var list:Array = _traitCollection.traits.list;
			while(list.length){
				_removeTrait(list[0]);
			}
		}
		protected function _removeTrait(trait:ITrait):void{
			CONFIG::debug{
				if(_root){
					Log.trace("WARNING:: ITrait being removed while ComposeItem added to root");
				}
			}
			trait.item = null;
			_traitCollection.removeTrait(trait);
			if(_parentItem)_parentItem.removeChildTrait(trait);
			
			for each(var concern:ITraitConcern in trait.concerns){
				removeTraitConcern(concern);
			}
		}
		
		
		protected function addTraitConcern(concern:ITraitConcern):void{
			if(concern.siblings){
				_siblingMarrier.addConcern(concern);
			}
		}
		protected function removeTraitConcern(concern:ITraitConcern):void{
			if(concern.siblings){
				_siblingMarrier.removeConcern(concern);
			}
		}
		
		
		protected function onParentAdd():void{
			for each(var trait:ITrait in _traitCollection.traits.list){
				_parentItem.addChildTrait(trait);
			}
		}
		protected function onParentRemove():void{
			for each(var trait:ITrait in _traitCollection.traits.list){
				_parentItem.removeChildTrait(trait);
			}
		}
		
		
		ComposeNamespace function addParentConcern(concern:ITraitConcern):void{
			_parentMarrier.addConcern(concern);
		}
		
		ComposeNamespace function removeParentConcern(concern:ITraitConcern):void{
			_parentMarrier.removeConcern(concern);
		}
	}
}
