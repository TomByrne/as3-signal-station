package org.tbyrne.debug.data.core
{
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.data.controls.ControlData;
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.data.dataTypes.IBitmapDataProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.debug.data.coreTypes.IDebugData;
	import org.tbyrne.display.core.ILayoutView;
	
	public class DebugData extends ControlData implements IDebugData
	{
		public function get bitmapDataValue():IBitmapDataProvider{
			return _bitmapDataValue;
		}
		public function set bitmapDataValue(value:IBitmapDataProvider):void{
			_bitmapDataValue = value;
		}
		
		public function get layoutView():ILayoutView{
			return _layoutView;
		}
		public function set layoutView(value:ILayoutView):void{
			_layoutView = value;
		}
		
		private var _layoutView:ILayoutView;
		private var _bitmapDataValue:IBitmapDataProvider;
		private var _childList:LinkedList;
		
		public function DebugData(label:IStringProvider=null, selectedAction:ITriggerableAction=null)
		{
			super(label);
			this.selectedAction = selectedAction;
		}
		
		public function addChildData(data:IDebugData):void{
			if(!_childList){
				_childList = new LinkedList();
				childData = _childList;
			}
			_childList.push(data);
		}
		public function removeChildData(data:IDebugData):void{
			if(_childList){
				_childList.removeFirst(data);
			}
		}
	}
}