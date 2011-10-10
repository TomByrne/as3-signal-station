package org.tbyrne.display.controls
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.layout.grid.IGridLayoutSubject;
	
	public class ListRenderer extends TextLabelButton implements IGridLayoutSubject
	{
		public function get columnIndex():int{
			return _columnIndex;
		}
		public function set columnIndex(value:int):void{
			attemptInit();
			if(_columnIndex!=value){
				_columnIndex = value;
				_oddEvenColumnState.selection = value%1;
			}
		}
		
		public function get rowIndex():int{
			return _rowIndex;
		}
		public function set rowIndex(value:int):void{
			attemptInit();
			if(_rowIndex!=value){
				_rowIndex = value;
				_oddEvenRowState.selection = value%1;
			}
		}
		
		private var _rowIndex:int;
		private var _columnIndex:int;
		
		private var _oddEvenRowState:StateDef;
		private var _oddEvenColumnState:StateDef;
		private var _hasChildrenState:StateDef;
		
		public function ListRenderer(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function fillStateList(fill:Array):Array{
			var ret:Array = super.fillStateList(fill);
			ret.push(_oddEvenRowState = new StateDef(["evenRow","oddRow"]));
			ret.push(_oddEvenColumnState = new StateDef(["evenColumn","oddColumn"]));
			ret.push(_hasChildrenState = new StateDef(["noChildren","hasChildren"],0));
			if(super.data)assessDataDrivenStates();
			return ret;
		}
		protected function assessDataDrivenStates():void{
			attemptInit()
			if(_data){
				_hasChildrenState.selection = (_data.childData==null)?0:1;
				if(!_data.active)active = true;
			}else{
				_hasChildrenState.selection = 0;
				if(!_data.active && (_data.selected!=null || _data.selectedAction!=null)){
					active = true;
				}
			}
		}
		
		override protected function assessData():void{
			super.assessData();
			assessDataDrivenStates();
		}
	}
}