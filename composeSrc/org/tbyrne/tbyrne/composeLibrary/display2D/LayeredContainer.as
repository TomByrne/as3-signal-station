package org.tbyrne.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.tbyrne.composeLibrary.types.display2D.IDisplayContainerTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.display2D.IDisplayObjectTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.display2D.ILayeredDisplayTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.draw.IFrameAwareTrait;
	import org.tbyrne.collections.IndexedList;
	
	public class LayeredContainer extends AbstractTrait implements IDisplayContainerTrait, IDisplayObjectTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get displayObjectChanged():IAct{
			return (_displayObjectChanged || (_displayObjectChanged = new Act()));
		}
		
		protected var _displayObjectChanged:Act;
		
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
							_display.setChildIndex(layer.displayObject,count);
							++count;
						}
					}
				}
			}
		}
		
		private var _defaultLayerArrangement:Vector.<String>;
		
		public function get displayObject():DisplayObject{
			return _display;
		}
		public function get display():DisplayObjectContainer{
			return _display;
		}
		public function set display(value:DisplayObjectContainer):void{
			_display = value;
		}
		
		private var _display:DisplayObjectContainer;
		
		private var _layerTraits:IndexedList;
		private var _layerIdLookup:Dictionary;
		
		public function LayeredContainer(display:DisplayObjectContainer=null){
			super();
			
			this.display = display;
			_layerTraits = new IndexedList();
			_layerIdLookup = new Dictionary();
			
			var concern:TraitConcern = new TraitConcern(true,true,ILayeredDisplayTrait);
			concern.stopDescendingAt = Vector.<Class>([IDisplayContainerTrait]);
			addConcern(concern);
		}
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var castTrait:ILayeredDisplayTrait = (trait as ILayeredDisplayTrait);
			
			var index:int;
			if(_defaultLayerArrangement && (index = _defaultLayerArrangement.indexOf(castTrait.layerId))!=-1){
				var addIndex:int = index>_display.numChildren?_display.numChildren:index;
				for each(var layerTrait:ILayeredDisplayTrait in _layerTraits.list){
					var idealIndex:int = _defaultLayerArrangement.indexOf(layerTrait.layerId);
					var realIndex:int = _display.getChildIndex(layerTrait.displayObject);
					if(idealIndex<index && realIndex>addIndex){
						addIndex = realIndex+1;
					}else if(idealIndex>index && realIndex<addIndex){
						addIndex = realIndex;
					}
				}
				_display.addChildAt(castTrait.displayObject, addIndex);
			}else{
				_display.addChild(castTrait.displayObject);
			}
			
			_layerTraits.push(castTrait);
			_layerIdLookup[castTrait.layerId] = castTrait;
			
			castTrait.moveAbove.addHandler(onMoveAbove);
			castTrait.moveBelow.addHandler(onMoveBelow);
			castTrait.moveUp.addHandler(onMoveUp);
			castTrait.moveDown.addHandler(onMoveDown);
			castTrait.moveToBottom.addHandler(onMoveToBottom);
			castTrait.moveToTop.addHandler(onMoveToTop);
		}
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			var castTrait:ILayeredDisplayTrait = (trait as ILayeredDisplayTrait);
			
			_layerTraits.remove(castTrait);
			delete _layerIdLookup[castTrait.layerId];
			
			_display.removeChild(castTrait.displayObject);
			
			castTrait.moveAbove.removeHandler(onMoveAbove);
			castTrait.moveBelow.removeHandler(onMoveBelow);
			castTrait.moveUp.removeHandler(onMoveUp);
			castTrait.moveDown.removeHandler(onMoveDown);
			castTrait.moveToBottom.removeHandler(onMoveToBottom);
			castTrait.moveToTop.removeHandler(onMoveToTop);
		}
		
		private function onMoveToTop(from:ILayeredDisplayTrait):void{
			_display.setChildIndex(from.displayObject, _display.numChildren-1);
		}
		private function onMoveToBottom(from:ILayeredDisplayTrait):void{
			_display.setChildIndex(from.displayObject, 0);
		}
		private function onMoveDown(from:ILayeredDisplayTrait):void{
			var index:int = _display.getChildIndex(from.displayObject);
			_display.swapChildrenAt(index, index-1);
		}
		private function onMoveUp(from:ILayeredDisplayTrait):void{
			var index:int = _display.getChildIndex(from.displayObject);
			_display.swapChildrenAt(index, index+1);
		}
		private function onMoveAbove(from:ILayeredDisplayTrait, aboveLayerId:String):void{
			var aboveTrait:ILayeredDisplayTrait = _layerIdLookup[aboveLayerId];
			var index:int = _display.getChildIndex(aboveTrait.displayObject);
			_display.setChildIndex(from.displayObject, index+1);
		}
		private function onMoveBelow(from:ILayeredDisplayTrait, belowLayerId:String):void{
			var belowTrait:ILayeredDisplayTrait = _layerIdLookup[belowLayerId];
			var index:int = _display.getChildIndex(belowTrait.displayObject);
			_display.setChildIndex(from.displayObject, index+1);
		}
		
	}
}