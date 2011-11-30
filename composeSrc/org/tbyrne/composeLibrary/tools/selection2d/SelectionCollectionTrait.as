package org.tbyrne.composeLibrary.tools.selection2d
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.controls.ISelectableCollection;
	
	public class SelectionCollectionTrait extends AbstractTrait implements ISelectionCollectionTrait
	{
		public function get selection():ISelectableCollection{
			return _selection;
		}
		public function get interested():ISelectableCollection{
			return _interested;
		}
		
		protected var _selectionChanged:Act;
		
		private var _selection:SelectableCollection;
		private var _interested:SelectableCollection;
		
		private var _selectables:Vector.<ISelectableTrait> = new Vector.<ISelectableTrait>();
		
		public function SelectionCollectionTrait(selection:Array=null){
			super();
			
			_selection = new SelectableCollection(_selectables,"selected");
			_interested = new SelectableCollection(_selectables,"interested");
			
			addConcern(new Concern(true,true,false,ISelectableTrait));
			
			if(selection){
				for each(var selectable:ISelectableTrait in selection){
					_selection.add(selectable,true);
				}
			}
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var selectableTrait:ISelectableTrait = (trait as ISelectableTrait);
			
			if(selectableTrait){
				_selectables.push(selectableTrait);
				if(selectableTrait.selected){
					_selection.add(selectableTrait,true);
				}
				if(selectableTrait.interested){
					_interested.add(selectableTrait,true);
				}
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var selectableTrait:ISelectableTrait = (trait as ISelectableTrait);
			
			if(selectableTrait){
				var index:int = _selectables.indexOf(selectableTrait);
				_selectables.splice(index,1);
				_selection.remove(selectableTrait);
				_interested.remove(selectableTrait);
			}
		}
	}
}