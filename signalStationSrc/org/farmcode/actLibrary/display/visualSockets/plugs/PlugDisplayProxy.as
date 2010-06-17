package org.farmcode.actLibrary.display.visualSockets.plugs
{
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.farmcode.display.behaviour.ViewBehaviour;
	
	public class PlugDisplayProxy extends AbstractPlugDisplayProxy
	{
		
		public function get target():ViewBehaviour{
			return _target;
		}
		public function set target(value:ViewBehaviour):void{
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
		
		public function PlugDisplayProxy(target:ViewBehaviour=null){
			super(target);
		}
		override public function setDataProvider(value:*, cause:IFillSocketAct=null):void{
			if(_dataProvider!=value){
				if(_target && _dataProvider && _dataField)uncommitData(cause);
				_dataProvider = value;
				if(_target && _dataProvider && _dataField)commitData(cause);
			}
		}
		override protected function commitData(cause:IFillSocketAct=null):void{
			_target[_dataField] = _dataProvider;
		}
		override protected function uncommitData(cause:IFillSocketAct=null):void{
			_target[_dataField] = null;
		}
	}
}