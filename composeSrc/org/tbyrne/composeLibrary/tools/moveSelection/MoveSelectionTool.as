package org.tbyrne.composeLibrary.tools.moveSelection
{
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectable2dTrait;
	import org.tbyrne.composeLibrary.tools.selection2d.ISelectorTrait;
	import org.tbyrne.composeLibrary.types.display2D.IPosition2dTrait;
	import org.tbyrne.composeLibrary.types.ui.IMouseActsTrait;
	
	public class MoveSelectionTool extends AbstractTrait
	{
		private var _selection:Vector.<IMouseActsTrait>;
		private var _positions:Vector.<IPosition2dTrait>;
		private var _selectorTrait:ISelectorTrait;
		
		public function MoveSelectionTool()
		{
			super();
			
			addConcern(new TraitConcern(true, false, ISelectorTrait));
		}
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var selectorTrait:ISelectorTrait;
			
			if(selectorTrait = (trait as ISelectorTrait)){
				_selectorTrait = selectorTrait;
				selectorTrait.selectionChanged.addHandler(onSelectionChanged);
				setSelection(selectorTrait.selection);
			}
		}
		
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
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
					mouseActTrait = getAct(selectable, IMouseActsTrait);
					positionTrait = getAct(selectable, IPosition2dTrait);
					if(mouseActTrait && positionTrait){
						if(!_selection){
							_selection = new Vector.<IMouseActsTrait>();
							_positions = new Vector.<IPosition2dTrait>();
						}
						mouseActTrait.mouseDragStart.addHandler(onDragStart);
						
						_selection.push(mouseActTrait);
						_positions.push(positionTrait);
					}
				}
			}
		}
		
		private function getAct(selectable:ISelectable2dTrait, traitType:Class):*{
			return (selectable as traitType) || selectable.item.getTrait(traitType);
		}
		
		private function onDragStart(from:IMouseActsTrait, info:IMouseActInfo):void{
			from.mouseDrag.addHandler(onDrag);
			from.mouseDragFinish.addHandler(onDragFinish);
		}
		
		private function onDrag(from:IMouseActsTrait, info:IMouseActInfo, byX:Number, byY:Number):void{
			for each(var position2d:IPosition2dTrait in _positions){
				position2d.setPosition2d(position2d.x2d + byX, position2d.y2d + byY);
			}
		}
		
		private function onDragFinish(from:IMouseActsTrait, info:IMouseActInfo):void{
			from.mouseDrag.removeHandler(onDrag);
			from.mouseDragFinish.removeHandler(onDragFinish);
		}
	}
}