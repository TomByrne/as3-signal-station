package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display2D.types.IDisplayContainerTrait;
	import org.tbyrne.composeLibrary.display2D.types.IDisplayObjectTrait;
	import org.tbyrne.composeLibrary.display2D.types.ILayerSortingTrait;
	import org.tbyrne.composeLibrary.display2D.types.ILayeredDisplayTrait;
	
	public class AbstractLayeredContainer extends AbstractTrait
	{
		
		public function get defaultLayerArrangement():Vector.<String>{
			return _defaultLayerArrangement;
		}
		public function set defaultLayerArrangement(value:Vector.<String>):void{
			if(_defaultLayerArrangement!=value){
				_defaultLayerArrangement = value;
				if(_defaultLayerArrangement){
					var count:int = 0;
					for(var i:int; i<_defaultLayerArrangement.length; ++i){
						var id:String = _defaultLayerArrangement[i];
						var layer:ILayeredDisplayTrait = _layerIdLookup[id];
						if(layer){
							setLayerIndex(layer, count);
							++count;
						}
					}
				}
			}
		}
		
		private var _defaultLayerArrangement:Vector.<String>;
		private var _layerTraits:IndexedList;
		private var _layerIdLookup:Dictionary;
		
		public function AbstractLayeredContainer(){
			super();
			_layerTraits = new IndexedList();
			_layerIdLookup = new Dictionary();
			
			addConcern(new Concern(true,true,false,IDisplayObjectTrait,[IDisplayContainerTrait]));
			addConcern(new Concern(true,true,false,ILayerSortingTrait));
		}
		
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var displayTrait:IDisplayObjectTrait = (trait as IDisplayObjectTrait);
			var layerSortingTrait:ILayerSortingTrait = (trait as ILayerSortingTrait);
			
			var doSuper:Boolean = true;
			
			if(displayTrait){
				doSuper = false;
				displayTrait.displayObjectChanged.addHandler(onDisplayObjectChanged);
				if(displayTrait.displayObject){
					assessAddDisplayTrait(displayTrait);
				}
			}
			if(layerSortingTrait){
				layerSortingTrait.moveAbove.addHandler(onMoveAbove);
				layerSortingTrait.moveBelow.addHandler(onMoveBelow);
				layerSortingTrait.moveUp.addHandler(onMoveUp);
				layerSortingTrait.moveDown.addHandler(onMoveDown);
				layerSortingTrait.moveToBottom.addHandler(onMoveToBottom);
				layerSortingTrait.moveToTop.addHandler(onMoveToTop);
			}
			if(doSuper){
				super.onConcernedTraitAdded(from,trait);
			}
		}
		
		private function onDisplayObjectChanged(displayTrait:IDisplayObjectTrait, oldDisplayObject:DisplayObject):void{
			if(oldDisplayObject){
				removeDisplayTrait(displayTrait, oldDisplayObject);
			}
			if(displayTrait.displayObject){
				assessAddDisplayTrait(displayTrait);
			}
		}
		
		private function assessAddDisplayTrait(displayTrait:IDisplayObjectTrait):void{
			var layeredDisplayTrait:ILayeredDisplayTrait = (displayTrait as ILayeredDisplayTrait);
			
			if(layeredDisplayTrait){
				var index:int;
				if(_defaultLayerArrangement && (index = _defaultLayerArrangement.indexOf(layeredDisplayTrait.layerId))!=-1){
					var addIndex:int = index>_layerTraits.list.length?_layerTraits.list.length:index;
					for each(var layerTrait:ILayeredDisplayTrait in _layerTraits.list){
						var idealIndex:int = _defaultLayerArrangement.indexOf(layerTrait.layerId);
						var realIndex:int = getLayerIndex(layerTrait);
						if(idealIndex<index && realIndex>addIndex){
							addIndex = realIndex+1;
						}else if(idealIndex>index && realIndex<addIndex){
							addIndex = realIndex;
						}
					}
					addLayerAt(layeredDisplayTrait, addIndex);
				}else{
					addDisplayTrait(displayTrait);
				}
				
				_layerTraits.push(layeredDisplayTrait);
				_layerIdLookup[layeredDisplayTrait.layerId] = layeredDisplayTrait;
				
			}else{
				addDisplayTrait(displayTrait);
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var doSuper:Boolean = true;
			
			var displayTrait:IDisplayObjectTrait = (trait as IDisplayObjectTrait);
			var layerSortingTrait:ILayerSortingTrait = (trait as ILayerSortingTrait);
			
			
			if(displayTrait){
				doSuper = false;
				displayTrait.displayObjectChanged.removeHandler(onDisplayObjectChanged);
				
				var layeredDisplayTrait:ILayeredDisplayTrait = (displayTrait as ILayeredDisplayTrait);
				if(layeredDisplayTrait){
					_layerTraits.remove(layeredDisplayTrait);
					delete _layerIdLookup[layeredDisplayTrait.layerId];
				}
				
				if(displayTrait.displayObject){
					removeDisplayTrait(displayTrait, displayTrait.displayObject);
				}
			}
			if(layerSortingTrait){
				layerSortingTrait.moveAbove.removeHandler(onMoveAbove);
				layerSortingTrait.moveBelow.removeHandler(onMoveBelow);
				layerSortingTrait.moveUp.removeHandler(onMoveUp);
				layerSortingTrait.moveDown.removeHandler(onMoveDown);
				layerSortingTrait.moveToBottom.removeHandler(onMoveToBottom);
				layerSortingTrait.moveToTop.removeHandler(onMoveToTop);
			}
			if(doSuper){
				super.onConcernedTraitRemoved(from,trait);
			}
		}
		
		protected function getLayer(layerId:String):ILayeredDisplayTrait{
			return _layerIdLookup[layerId];
		}
		
		protected function getLayerIndex(layer:ILayeredDisplayTrait):int{
			// override me
			return -1;
		}
		protected function setLayerIndex(layer:ILayeredDisplayTrait, count:int):void{
			// override me
		}
		protected function addLayerAt(layer:ILayeredDisplayTrait, addIndex:int):void{
			// override me
		}
		protected function addDisplayTrait(displayTrait:IDisplayObjectTrait):void{
			// override me
		}
		protected function removeDisplayTrait(displayTrait:IDisplayObjectTrait, displayObject:DisplayObject):void{
			// override me
		}
		
		protected function onMoveToTop(from:ILayerSortingTrait, layerId:String):void{
			var layerTrait:ILayeredDisplayTrait = getLayer(layerId);
			setLayerIndex(layerTrait, _layerTraits.list.length-1);
		}
		protected function onMoveToBottom(from:ILayerSortingTrait, layerId:String):void{
			var layerTrait:ILayeredDisplayTrait = getLayer(layerId);
			setLayerIndex(layerTrait, 0);
		}
		protected function onMoveDown(from:ILayerSortingTrait, layerId:String):void{
			var layerTrait:ILayeredDisplayTrait = getLayer(layerId);
			var index:int = getLayerIndex(layerTrait);
			setLayerIndex(layerTrait, index-1);
		}
		protected function onMoveUp(from:ILayerSortingTrait, layerId:String):void{
			var layerTrait:ILayeredDisplayTrait = getLayer(layerId);
			var index:int = getLayerIndex(layerTrait);
			setLayerIndex(layerTrait, index+1);
		}
		protected function onMoveAbove(from:ILayerSortingTrait, layerId:String, aboveLayerId:String):void{
			var layerTrait:ILayeredDisplayTrait = getLayer(layerId);
			var aboveTrait:ILayeredDisplayTrait = getLayer(aboveLayerId);
			var index:int = getLayerIndex(aboveTrait);
			setLayerIndex(layerTrait, index+1);
		}
		protected function onMoveBelow(from:ILayerSortingTrait, layerId:String, belowLayerId:String):void{
			var layerTrait:ILayeredDisplayTrait = getLayer(layerId);
			var belowTrait:ILayeredDisplayTrait = getLayer(belowLayerId);
			var index:int = getLayerIndex(belowTrait);
			setLayerIndex(layerTrait, index+1);
		}
	}
}