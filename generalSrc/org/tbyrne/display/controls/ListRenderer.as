package org.tbyrne.display.controls
{
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.IDataProvider;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.layout.grid.IGridLayoutSubject;
	
	public class ListRenderer extends TextLabelButton implements IGridLayoutSubject
	{
		public function get columnIndex():int{
			return _columnIndex;
		}
		public function set columnIndex(value:int):void{
			if(_columnIndex!=value){
				_columnIndex = value;
				_oddEvenColumnState.selection = value%1;
			}
		}
		
		public function get rowIndex():int{
			return _rowIndex;
		}
		public function set rowIndex(value:int):void{
			if(_rowIndex!=value){
				_rowIndex = value;
				_oddEvenRowState.selection = value%1;
			}
		}
		
		override public function set data(value:*):void{
			if(super.data != value){
				super.data = value;
				if(_hasChildrenState){
					assessDataDrivenStates();
				}
			}
		}
		
		private var _rowIndex:int;
		private var _columnIndex:int;
		
		private var _oddEvenRowState:StateDef;
		private var _oddEvenColumnState:StateDef;
		private var _hasChildrenState:StateDef;
		
		public function ListRenderer(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function fillStateList(fill:Array):Array{
			var ret:Array = super.fillStateList(fill);
			ret.push(_oddEvenRowState = new StateDef(["evenRow","oddRow"]));
			ret.push(_oddEvenColumnState = new StateDef(["evenColumn","oddColumn"]));
			ret.push(_hasChildrenState = new StateDef(["noChildren","hasChildren"]));
			if(super.data)assessDataDrivenStates();
			return ret;
		}
		protected function assessDataDrivenStates():void{
			var dataProv:IDataProvider = (data as IDataProvider);
			if(dataProv){
				_hasChildrenState.selection = (dataProv.data==null)?0:1;
				active = true;
			}else{
				_hasChildrenState.selection = -1;
				var boolProv:IBooleanProvider = (data as IBooleanProvider);
				active = (boolProv!=null);
			}
		}
	}
}