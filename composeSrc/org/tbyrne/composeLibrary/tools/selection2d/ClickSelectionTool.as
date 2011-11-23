package org.tbyrne.composeLibrary.tools.selection2d
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.ui.types.IMouseActsTrait;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	
	public class ClickSelectionTool extends AbstractTrait
	{
		
		public function get addToSelection():IBooleanProvider{
			return _addToSelection;
		}
		public function set addToSelection(value:IBooleanProvider):void{
			if(_addToSelection!=value){
				_addToSelection = value;
			}
		}
		public function get selectOnDrag():Boolean{
			return _selectOnDrag;
		}
		public function set selectOnDrag(value:Boolean):void{
			if(_selectOnDrag!=value){
				_selectOnDrag = value;
			}
		}
		
		private var _selectOnDrag:Boolean;
		
		private var _addToSelection:IBooleanProvider;
		private var _selectionColl:ISelectionCollectionTrait;
		private var _mouseActsTrait:IMouseActsTrait;
		private var _deselectTimer:Timer = new Timer(1,1);;
		
		public function ClickSelectionTool(addToSelection:IBooleanProvider=null, selectOnDrag:Boolean=false)
		{
			super();
			_deselectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDeselectTimer);
			
			this.addToSelection = addToSelection;
			this.selectOnDrag = selectOnDrag;
			
			addConcern(new Concern(true,true,false,ISelectableTrait));
			addConcern(new Concern(true,false,false,ISelectionCollectionTrait));
			addConcern(new Concern(true,false,false,IMouseActsTrait));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var selectableTrait:ISelectableTrait;
			var selectionColl:ISelectionCollectionTrait;
			var mouseActsTrait:IMouseActsTrait;
			
			if(selectableTrait = (trait as ISelectableTrait)){
				mouseActsTrait = trait.item.getTrait(IMouseActsTrait);
				mouseActsTrait.mouseClick.addHandler(onMouseClicked, [selectableTrait]);
				mouseActsTrait.mouseDragStart.addHandler(onMouseDragStart, [selectableTrait]);
				mouseActsTrait.mouseIsOver.booleanValueChanged.addHandler(onMouseOverChanged, [selectableTrait]);
			}
			if(mouseActsTrait = (trait as IMouseActsTrait)){
				mouseActsTrait.mouseClick.addHandler(onBroadMouseClicked);
			}
			if(selectionColl = (trait as ISelectionCollectionTrait)){
				_selectionColl = selectionColl;
			}
		}
		
		private function onBroadMouseClicked(from:IMouseActsTrait, info:IMouseActInfo):void{
			_deselectTimer.reset();
			_deselectTimer.start();
		}
		
		protected function onDeselectTimer(event:TimerEvent):void{
			_selectionColl.selection.removeAll();
		}
		
		private function onMouseOverChanged(from:IBooleanProvider, selectableTrait:ISelectableTrait):void{
			if(from.booleanValue){
				_selectionColl.interested.add(selectableTrait,true);
			}else{
				_selectionColl.interested.remove(selectableTrait);
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var selectableTrait:ISelectableTrait;
			var selectionColl:ISelectionCollectionTrait;
			var mouseActsTrait:IMouseActsTrait;
			
			if(selectableTrait = (trait as ISelectableTrait)){
				mouseActsTrait = trait.item.getTrait(IMouseActsTrait);
				mouseActsTrait.mouseClick.removeHandler(onMouseClicked);
				mouseActsTrait.mouseDragStart.removeHandler(onMouseDragStart);
				mouseActsTrait.mouseIsOver.booleanValueChanged.addHandler(onMouseOverChanged, [selectableTrait]);
			}
			if(mouseActsTrait = (trait as IMouseActsTrait)){
				mouseActsTrait.mouseClick.removeHandler(onBroadMouseClicked);
			}
			if(selectionColl = (trait as ISelectionCollectionTrait)){
				_selectionColl = null;
			}
		}
		
		private function onMouseClicked(from:IMouseActsTrait, mouseActInfo:IMouseActInfo, selectableTrait:ISelectableTrait):void{
			_deselectTimer.stop();
			var add:Boolean = _addToSelection.booleanValue;
			if(!selectableTrait.selected){
				_selectionColl.selection.add(selectableTrait,add);
			}else if(add){
				_selectionColl.selection.remove(selectableTrait);
			}
		}
		
		private function onMouseDragStart(from:IMouseActsTrait, mouseActInfo:IMouseActInfo, selectableTrait:ISelectableTrait):void{
			if(_selectOnDrag)onMouseClicked(from, mouseActInfo, selectableTrait);
		}
	}
}