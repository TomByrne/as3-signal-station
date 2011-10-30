package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display2D.IDisplayContainerTrait;
	import org.tbyrne.composeLibrary.types.display2D.IDisplayObjectTrait;
	import org.tbyrne.composeLibrary.types.display2D.ILayeredDisplayTrait;
	import org.tbyrne.composeLibrary.types.draw.IFrameAwareTrait;
	
	public class LayeredContainer extends DisplayObjectContainerTrait
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
							_container.setChildIndex(layer.displayObject,count);
							++count;
						}
					}
				}
			}
		}
		
		private var _defaultLayerArrangement:Vector.<String>;
		
		
		private var _layerTraits:IndexedList;
		private var _layerIdLookup:Dictionary;
		
		public function LayeredContainer(display:DisplayObjectContainer=null){
			super(display);
			_layerTraits = new IndexedList();
			_layerIdLookup = new Dictionary();
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var castTrait:ILayeredDisplayTrait = (trait as ILayeredDisplayTrait);
			
			if(castTrait){
				var index:int;
				if(_defaultLayerArrangement && (index = _defaultLayerArrangement.indexOf(castTrait.layerId))!=-1){
					var addIndex:int = index>_container.numChildren?_container.numChildren:index;
					for each(var layerTrait:ILayeredDisplayTrait in _layerTraits.list){
						var idealIndex:int = _defaultLayerArrangement.indexOf(layerTrait.layerId);
						var realIndex:int = _container.getChildIndex(layerTrait.displayObject);
						if(idealIndex<index && realIndex>addIndex){
							addIndex = realIndex+1;
						}else if(idealIndex>index && realIndex<addIndex){
							addIndex = realIndex;
						}
					}
					_container.addChildAt(castTrait.displayObject, addIndex);
				}else{
					_container.addChild(castTrait.displayObject);
				}
				
				_layerTraits.push(castTrait);
				_layerIdLookup[castTrait.layerId] = castTrait;
				
				castTrait.moveAbove.addHandler(onMoveAbove);
				castTrait.moveBelow.addHandler(onMoveBelow);
				castTrait.moveUp.addHandler(onMoveUp);
				castTrait.moveDown.addHandler(onMoveDown);
				castTrait.moveToBottom.addHandler(onMoveToBottom);
				castTrait.moveToTop.addHandler(onMoveToTop);
			}else{
				super.onConcernedTraitAdded(from,trait);
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var castTrait:ILayeredDisplayTrait = (trait as ILayeredDisplayTrait);
			
			if(castTrait){
				_layerTraits.remove(castTrait);
				delete _layerIdLookup[castTrait.layerId];
				
				_container.removeChild(castTrait.displayObject);
				
				castTrait.moveAbove.removeHandler(onMoveAbove);
				castTrait.moveBelow.removeHandler(onMoveBelow);
				castTrait.moveUp.removeHandler(onMoveUp);
				castTrait.moveDown.removeHandler(onMoveDown);
				castTrait.moveToBottom.removeHandler(onMoveToBottom);
				castTrait.moveToTop.removeHandler(onMoveToTop);
			}else{
				super.onConcernedTraitRemoved(from,trait);
			}
		}
		
		private function onMoveToTop(from:ILayeredDisplayTrait):void{
			_container.setChildIndex(from.displayObject, _container.numChildren-1);
		}
		private function onMoveToBottom(from:ILayeredDisplayTrait):void{
			_container.setChildIndex(from.displayObject, 0);
		}
		private function onMoveDown(from:ILayeredDisplayTrait):void{
			var index:int = _container.getChildIndex(from.displayObject);
			_container.swapChildrenAt(index, index-1);
		}
		private function onMoveUp(from:ILayeredDisplayTrait):void{
			var index:int = _container.getChildIndex(from.displayObject);
			_container.swapChildrenAt(index, index+1);
		}
		private function onMoveAbove(from:ILayeredDisplayTrait, aboveLayerId:String):void{
			var aboveTrait:ILayeredDisplayTrait = _layerIdLookup[aboveLayerId];
			var index:int = _container.getChildIndex(aboveTrait.displayObject);
			_container.setChildIndex(from.displayObject, index+1);
		}
		private function onMoveBelow(from:ILayeredDisplayTrait, belowLayerId:String):void{
			var belowTrait:ILayeredDisplayTrait = _layerIdLookup[belowLayerId];
			var index:int = _container.getChildIndex(belowTrait.displayObject);
			_container.setChildIndex(from.displayObject, index+1);
		}
		
	}
}