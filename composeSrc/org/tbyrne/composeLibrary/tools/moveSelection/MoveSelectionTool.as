package org.tbyrne.composeLibrary.tools.moveSelection
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.controls.ISelectableCollection;
	import org.tbyrne.composeLibrary.display2D.types.IPosition2dTrait;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectableTrait;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectionCollectionTrait;
	import org.tbyrne.composeLibrary.ui.types.IMouseActsTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class MoveSelectionTool extends AbstractTrait
	{
		public function get moving():Boolean{
			return _moving;
		}
		
		
		private var _moving:Boolean;
		private var _activeMouse:IMouseActsTrait;
		private var _posTraits:Vector.<IPosition2dTrait>;
		private var _moveTraits:Vector.<IMoveTrait>;
		private var _mouseTraits:Vector.<IMouseActsTrait>;
		private var _selectorTrait:ISelectionCollectionTrait;
		//private var _mouseActTrait:IMouseActsTrait;
		
		public function MoveSelectionTool()
		{
			super();
			addConcern(new Concern(true, false,false, ISelectionCollectionTrait));
			//addConcern(new Concern(true, false,false, IMouseActsTrait));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var selectorTrait:ISelectionCollectionTrait;
			//var mouseActTrait:IMouseActsTrait;
			
			if(selectorTrait = (trait as ISelectionCollectionTrait)){
				_selectorTrait = selectorTrait;
				selectorTrait.selection.collectionChanged.addHandler(onSelectionChanged);
				setSelection(selectorTrait.selection.list);
			}
			/*if(mouseActTrait = (trait as IMouseActsTrait)){
				_mouseActTrait = mouseActTrait;
				_mouseActTrait.mouseDragStart.addHandler(onDragStart);
			}*/
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var selectorTrait:ISelectionCollectionTrait;
			//var mouseActTrait:IMouseActsTrait;
			
			if(selectorTrait = (trait as ISelectionCollectionTrait)){
				setSelection(null);
				_selectorTrait.selection.collectionChanged.removeHandler(onSelectionChanged);
				_selectorTrait = null;
			}
			/*if(mouseActTrait = (trait as IMouseActsTrait)){
				_mouseActTrait = mouseActTrait;
				_mouseActTrait.mouseDragStart.removeHandler(onDragStart);
			}*/
		}
		
		
		private function onSelectionChanged(selectorTrait:ISelectableCollection):void{
			setSelection(_selectorTrait.selection.list);
		}
		
		private function setSelection(selection:Vector.<ISelectableTrait>):void{
			var selectable:ISelectableTrait;
			var positionTrait:IPosition2dTrait;
			var mouseTrait:IMouseActsTrait;
			if(_posTraits){
				for each(mouseTrait in _mouseTraits){
					mouseTrait.mouseDragStart.removeHandler(onDragStart);
				}
				if(_moving)onDragFinish(_activeMouse, null);
			}
			
			_posTraits = null;
			_moveTraits = null;
			_mouseTraits = null;
			var dragging:IMouseActsTrait;
			if(selection){
				for each(selectable in selection){
					positionTrait = getAct(selectable, IPosition2dTrait, false);
					mouseTrait = getAct(selectable, IMouseActsTrait, false);
					if(positionTrait && mouseTrait){
						if(!_posTraits){
							_posTraits = new Vector.<IPosition2dTrait>();
							_moveTraits = new Vector.<IMoveTrait>();
							_mouseTraits = new Vector.<IMouseActsTrait>();
						}
						var moveTrait:IMoveTrait = getAct(selectable, IMoveTrait, true);
						
						_posTraits.push(positionTrait);
						_mouseTraits.push(mouseTrait);
						if(moveTrait)_moveTraits.push(moveTrait);
						
						mouseTrait.mouseDragStart.addHandler(onDragStart);
						if(mouseTrait.mouseIsDragging.booleanValue){
							dragging = mouseTrait;
						}
						
					}
				}
				if(dragging){
					onDragStart(dragging,null);
				}
			}
		}
		
		private function getAct(selectable:ISelectableTrait, traitType:Class, doDesc:Boolean):*{
			var ret:* = (selectable as traitType) || selectable.item.getTrait(traitType);
			if(!ret && doDesc){
				ret = (selectable.item as ComposeGroup).getDescTrait(traitType);
			}
			return ret;
		}
		
		private function onDragStart(from:IMouseActsTrait, info:IMouseActInfo):void{
			_moving = true;
			
			var dragPositions:Vector.<Point> = new Vector.<Point>();
			for each(var position2d:IPosition2dTrait in _posTraits){
				dragPositions.push(new Point(position2d.x2d, position2d.y2d));
			}
			from.mouseDrag.addHandler(onDrag,[dragPositions]);
			from.mouseDragFinish.addHandler(onDragFinish);
			
			for each(var moveTrait:IMoveTrait in _moveTraits){
				moveTrait.isMoving = true;
			}
			_activeMouse = from;
		}
		
		private function onDrag(from:IMouseActsTrait, info:IMouseActInfo, byX:Number, byY:Number, dragPositions:Vector.<Point>):void{
			if(!_posTraits)return;
			
			for(var i:int=0; i<_posTraits.length; ++i){
				
				var position2d:IPosition2dTrait = _posTraits[i];
				var dragPoint:Point = dragPositions[i];
				dragPoint.x += byX;
				dragPoint.y += byY;
				
				position2d.setPosition2d(dragPoint.x, dragPoint.y);
			}
		}
		
		private function onDragFinish(from:IMouseActsTrait, info:IMouseActInfo):void{
			_moving = false;
			from.mouseDrag.removeHandler(onDrag);
			from.mouseDragFinish.removeHandler(onDragFinish);
			
			for each(var moveTrait:IMoveTrait in _moveTraits){
				moveTrait.isMoving = false;
			}
			_activeMouse = null;
		}
	}
}