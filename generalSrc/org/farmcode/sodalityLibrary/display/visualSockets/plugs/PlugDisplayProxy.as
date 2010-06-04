package org.farmcode.sodalityLibrary.display.visualSockets.plugs
{
	import org.farmcode.display.behaviour.ViewBehaviour;
	import org.farmcode.sodality.advice.IAdvice;
	
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
		override public function setDataProvider(value:*, cause:IAdvice=null):void{
			if(_dataProvider!=value){
				if(_target && _dataProvider && _dataField)uncommitData(cause);
				_dataProvider = value;
				if(_target && _dataProvider && _dataField)commitData(cause);
			}
		}
		override protected function commitData(cause:IAdvice=null):void{
			_target[_dataField] = _dataProvider;
		}
		override protected function uncommitData(cause:IAdvice=null):void{
			_target[_dataField] = null;
		}
	}
}