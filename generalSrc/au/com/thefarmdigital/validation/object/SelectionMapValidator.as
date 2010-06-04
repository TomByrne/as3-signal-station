package au.com.thefarmdigital.validation.object
{
	import au.com.thefarmdigital.structs.SelectionMap;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.Validator;
	
	/**
	 * The SelectionMapValidator is used internally by the List component
	 * to manage which items within the list are selected.<br>
	 * It can validate the selection by minimum/maximum amount of items selected.<br>
	 * In the case of the List class it will perform live validation,
	 * meaning that every time the Lists selection changes, the validator will be run
	 * and attempt to fix any validation problems. This means that if the maximum amount
	 * of items gets selected, the first item selected will be unselected. Likewise,
	 * if an item is unselected and the minimum selected items rule becomes invalid
	 * the item will immediately be reselected.
	 */
	public class SelectionMapValidator extends Validator
	{
		public function get maximumSelected():int{
			return _maximumSelected;
		}
		public function set maximumSelected(value:int):void{
			if(_maximumSelected != value){
				_maximumSelected = value;
				validateIfLive();
			}
		}
		
		public function get minimumSelected():int{
			return _minimumSelected;
		}
		public function set minimumSelected(value:int):void{
			if(_minimumSelected != value){
				_minimumSelected = value;
				validateIfLive();
			}
		}
		
		/**
		 * If unselectable is false then items can not be unselected unless
		 * the maximum selected amount gets reached, at which point items will
		 * be unselected in the order they were selected.
		 */
		public var unselectable:Boolean = true;
		
		private var _minimumSelected:int = 0;
		private var _maximumSelected:int = -1;
		
		public function SelectionMapValidator(subject:*=null, validationKey:String=null, liveValidation:Boolean=false){
			super(subject, validationKey, liveValidation);
		}
		
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			var selectionMap:SelectionMap = value;
			var culprit:int;
			
			if(!unselectable){
				culprit = selectionMap.getLastCulpritIndex();
				if(culprit!=-1 && !selectionMap.isSelected(culprit)){
					selectionMap.setSelected(culprit,true,true);
				}
			}
			
			var selected:int = selectionMap.getSelectedCount();
			if(minimumSelected!=-1){
				while(selected<minimumSelected && culprit!=-1){
					culprit = selectionMap.getFirstCulprit();
					if(!selectionMap.isSelected(culprit)){
						selectionMap.setSelected(culprit,true,false);
						selected++;
					}
				}
			}
			
			culprit = 0;
			if(maximumSelected!=-1){
				while(selected>maximumSelected && culprit!=-1){
					culprit = selectionMap.getFirstCulprit();
					if(selectionMap.isSelected(culprit)){
						selectionMap.setSelected(culprit,false,false);
						selected--;
					}
				}
			}
			return value;
		}
	}
}