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
	import org.tbyrne.composeLibrary.display2D.types.IPosition2dTrait;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectable2dTrait;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectorTrait;
	import org.tbyrne.composeLibrary.ui.types.IMouseActsTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class MoveSelectionTool extends AbstractTrait
	{
		public function get moving():Boolean{
			return _movingCount>0;
		}
		
		
		private var _movingCount:int;
		private var _selection:Vector.<IMouseActsTrait>;
		private var _positions:Vector.<IPosition2dTrait>;
		private var _selectorTrait:ISelectorTrait;
		
		public function MoveSelectionTool()
		{
			super();
			addConcern(new Concern(true, false,false, ISelectorTrait));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var selectorTrait:ISelectorTrait;
			
			if(selectorTrait = (trait as ISelectorTrait)){
				_selectorTrait = selectorTrait;
				selectorTrait.selectionChanged.addHandler(onSelectionChanged);
				setSelection(selectorTrait.selection);
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var selectorTrait:ISelectorTrait;
			
			if(selectorTrait = (trait as ISelectorTrait)){
				_selectorTrait.selectionChanged.removeHandler(onSelectionChanged);
				_selectorTrait = null;
			}
		}
		
		
		private function onSelectionChanged(selectorTrait:ISelectorTrait):void{
			setSelection(_selectorTrait.selection);
		}
		
		private function setSelection(selection:Vector.<ISelectable2dTrait>):void{
			var selectable:ISelectable2dTrait;
			var mouseActTrait:IMouseActsTrait;
			var positionTrait:IPosition2dTrait;
			
			if(_selection){
				for each(mouseActTrait in _selection){
					mouseActTrait.mouseDragStart.removeHandler(onDragStart);
				}
			}
			_selection = null;
			if(selection){
				for each(selectable in selection){
					mouseActTrait = getAct(selectable, IMouseActsTrait, false);
					positionTrait = getAct(selectable, IPosition2dTrait, false);
					if(mouseActTrait && positionTrait){
						if(!_selection){
							_selection = new Vector.<IMouseActsTrait>();
							_positions = new Vector.<IPosition2dTrait>();
						}
						var moveTrait:IMoveTrait = getAct(selectable, IMoveTrait, true);
						mouseActTrait.mouseDragStart.addHandler(onDragStart,[moveTrait]);
						
						_selection.push(mouseActTrait);
						_positions.push(positionTrait);
						
						if(mouseActTrait.mouseIsDragging.booleanValue){
							onDragStart(mouseActTrait, null, moveTrait);
						}
					}
				}
			}
		}
		
		private function getAct(selectable:ISelectable2dTrait, traitType:Class, doDesc:Boolean):*{
			var ret:* = (selectable as traitType) || selectable.item.getTrait(traitType);
			if(!ret && doDesc){
				ret = (selectable.item as ComposeGroup).getDescTrait(traitType);
			}
			return ret;
		}
		
		private function onDragStart(from:IMouseActsTrait, info:IMouseActInfo, moveTrait:IMoveTrait):void{
			++_movingCount;
			
			//trace("start: "+from.localMouseX.numericalValue, from.localMouseY.numericalValue);
			
			var localX:Number = from.localMouseX.numericalValue;
			var localY:Number = from.localMouseY.numericalValue;
			
			var dragPositions:Vector.<Point> = new Vector.<Point>();
			for each(var position2d:IPosition2dTrait in _positions){
				dragPositions.push(new Point(position2d.x2d, position2d.y2d));
				
			}
			from.mouseDrag.addHandler(onDrag,[dragPositions]);
			from.mouseDragFinish.addHandler(onDragFinish,[moveTrait]);
			if(moveTrait)moveTrait.isMoving = true;
		}
		
		private function onDrag(from:IMouseActsTrait, info:IMouseActInfo, byX:Number, byY:Number, dragPositions:Vector.<Point>):void{
			
			
			//trace("\t"+from.localMouseX.numericalValue, from.localMouseY.numericalValue);
			
			var localX:Number = from.localMouseX.numericalValue;
			var localY:Number = from.localMouseY.numericalValue;
			
			for(var i:int=0; i<_positions.length; ++i){
				
				var position2d:IPosition2dTrait = _positions[i];
				var dragPoint:Point = dragPositions[i];
				dragPoint.x += byX;
				dragPoint.y += byY;
				
				position2d.setPosition2d(dragPoint.x, dragPoint.y);
			}
		}
		
		private function onDragFinish(from:IMouseActsTrait, info:IMouseActInfo, moveTrait:IMoveTrait):void{
			--_movingCount;
			from.mouseDrag.removeHandler(onDrag);
			from.mouseDragFinish.removeHandler(onDragFinish);
			if(moveTrait)moveTrait.isMoving = false;
		}
	}
}