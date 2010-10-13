package org.tbyrne.actLibrary.display.visualSockets.plugs
{
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.display.core.DrawableView;
	
	public class PlugDisplayProxy extends AbstractPlugDisplayProxy
	{
		
		public function get target():DrawableView{
			return _target;
		}
		public function set target(value:DrawableView):void{
			setTarget(value);
		}
		
		public function get dataField():String{
			return _dataField;
		}
		public function set dataField(value:String):void{
			if(_dataField!=value){
				if(_target && _dataProvider && _dataField)uncommitData();
				_dataField = value;
				if(_target && _dataProvider && _dataField)commitData();
			}
		}
		
		private var _dataField:String;
		
		public function PlugDisplayProxy(target:DrawableView=null){
			super(target);
		}
		override public function setDataProvider(value:*, execution:UniversalActExecution=null):void{
			if(_dataProvider!=value){
				if(_target && _dataProvider && _dataField)uncommitData(execution);
				_dataProvider = value;
				if(_target && _dataProvider && _dataField)commitData(execution);
			}
		}
		override protected function commitData(execution:UniversalActExecution=null):void{
			_target[_dataField] = _dataProvider;
		}
		override protected function uncommitData(execution:UniversalActExecution=null):void{
			_target[_dataField] = null;
		}
	}
}