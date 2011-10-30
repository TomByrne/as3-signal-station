package org.tbyrne.compose.core
{
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.ComposeNamespace;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.compose.traits.TraitCollection;
	
	use namespace ComposeNamespace;
	
	public class ComposeGroup extends ComposeItem
	{
		
		private var _descendantTraits:TraitCollection = new TraitCollection();
		private var _children:IndexedList = new IndexedList();
		private var _descConcerns:IndexedList = new IndexedList();
		private var _parentDescConcerns:IndexedList = new IndexedList();
		private var _ignoredParentConcerns:IndexedList = new IndexedList();
		
		public function ComposeGroup(initTraits:Array=null){
			super(initTraits);
		}
		override ComposeNamespace function setRoot(game:ComposeRoot):void{
			super.setRoot(game);
			for each(var child:ComposeItem in _children.list){
				child.setRoot(game);
			}
		}
		public function addItem(item:ComposeItem):void{
			CONFIG::debug{
				if(!item)Log.error("ComposeGroup.addItem must have child ComposeItem supplied");
				if(_children.containsItem(item))Log.error("ComposeGroup.addItem already contains child item.");
			}
			
			_children.push(item);
			item.parentItem = this;
			
			var traitConcern:IConcern;
			for each(traitConcern in _descConcerns.list){
				item.addParentConcern(traitConcern);
			}
			for each(traitConcern in _parentDescConcerns.list){
				item.addParentConcern(traitConcern);
			}
			
			item.setRoot(_root);
		}
		public function removeItem(item:ComposeItem):void{
			CONFIG::debug{
				if(!item)Log.error("ComposeGroup.removeItem must have child ComposeItem supplied");
				if(!_children.containsItem(item))Log.error("ComposeGroup.removeItem doesn't contain child item.");
			}
			
			_children.remove(item);
			item.parentItem = null;
			
			var traitConcern:IConcern;
			for each(traitConcern in _descConcerns.list){
				item.removeParentConcern(traitConcern);
			}
			for each(traitConcern in _parentDescConcerns.list){
				item.removeParentConcern(traitConcern);
			}
			
			item.setRoot(null);
		}
		public function removeAllItem():void{
			while( _children.list.length ){
				removeItem(_children.list[0]);
			}
		}
		ComposeNamespace function addChildTrait(trait:ITrait):void{
			_descendantTraits.addTrait(trait);
			if(_parentItem)_parentItem.addChildTrait(trait);
		}
		ComposeNamespace function removeChildTrait(trait:ITrait):void{
			_descendantTraits.removeTrait(trait);
			if(_parentItem)_parentItem.removeChildTrait(trait);
		}
		override public function addTrait(trait:ITrait):void{
			super.addTrait(trait);
			checkParentConcerns();
		}
		override public function addTraits(traits:Vector.<ITrait>):void{
			super.addTraits(traits);
			checkParentConcerns();
		}
		override public function removeTrait(trait:ITrait):void{
			super.removeTrait(trait);
			uncheckParentConcerns();
		}
		override public function removeTraits(traits:Vector.<ITrait>):void{
			super.removeTraits(traits);
			uncheckParentConcerns();
		}
		override public function removeAllTraits():void{
			super.removeAllTraits();
			uncheckParentConcerns();
		}
		override protected function addTraitConcern(concern:IConcern):void{
			super.addTraitConcern(concern);
			if(concern.descendants){
				_descConcerns.push(concern);
				for each(var child:ComposeItem in _children.list){
					child.addParentConcern(concern);
				}
			}
		}
		override protected function removeTraitConcern(concern:IConcern):void{
			super.removeTraitConcern(concern);
			if(_descConcerns.containsItem(concern)){
				_descConcerns.remove(concern);
				for each(var child:ComposeItem in _children.list){
					child.removeParentConcern(concern);
				}
			}
		}
		public function getDescTrait(matchType:Class):*{
			return _descendantTraits.getTrait(matchType);
		}
		public function getDescTraits(ifMatches:Class=null):Array{
			return _descendantTraits.getTraits(ifMatches);
		}
		public function callForDescTraits(func:Function, ifMatches:Class=null, params:Array=null):void{
			_descendantTraits.callForTraits(func, ifMatches, this, params);
		}
		override protected function onParentAdd():void{
			super.onParentAdd();
			for each(var trait:ITrait in _descendantTraits.traits){
				_parentItem.addChildTrait(trait);
			}
		}
		override protected function onParentRemove():void{
			super.onParentRemove();
			for each(var trait:ITrait in _descendantTraits.traits){
				_parentItem.removeChildTrait(trait);
			}
		}
		
		
		override ComposeNamespace function addParentConcern(concern:IConcern):void{
			super.addParentConcern(concern);
			if(concern.shouldDescend(this)){
				addDescParentConcern(concern);
			}else{
				_ignoredParentConcerns.push(concern);
			}
		}
		
		override ComposeNamespace function removeParentConcern(concern:IConcern):void{
			super.removeParentConcern(concern);
			
			if(_parentDescConcerns.containsItem(concern)){
				removeDescParentConcern(concern);
			}else{
				_ignoredParentConcerns.remove(concern);
			}
		}
		
		protected function checkParentConcerns():void{
			var i:int=0;
			while(i<_parentDescConcerns.list.length){
				var concern:IConcern = _parentDescConcerns.list[i];
				if(!concern.shouldDescend(this)){
					removeDescParentConcern(concern);
					_ignoredParentConcerns.push(concern);
				}else{
					++i
				}
			}
		}
		protected function uncheckParentConcerns():void{
			var i:int=0;
			while(i<_ignoredParentConcerns.list.length){
				var concern:IConcern = _ignoredParentConcerns.list[i];
				if(concern.shouldDescend(this)){
					addDescParentConcern(concern);
					_ignoredParentConcerns.remove(concern);
				}else{
					++i;
				}
			}
		}
		
		
		protected function addDescParentConcern(concern:IConcern):void{
			_parentDescConcerns.push(concern);
			for each(var child:ComposeItem in _children.list){
				child.addParentConcern(concern);
			}
		}
		private function removeDescParentConcern(concern:IConcern):void{
			_parentDescConcerns.remove(concern);
			for each(var child:ComposeItem in _children.list){
				child.removeParentConcern(concern);
			}
		}
	}
}