package org.tbyrne.data.actions
{
	import org.tbyrne.data.dataTypes.IBooleanData;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public class ToggleBooleanAction implements ITriggerableAction
	{
		
		public function get boolean():IBooleanData{
			return _boolean;
		}
		public function set boolean(value:IBooleanData):void{
			if(_boolean!=value){
				_boolean = value;
			}
		}
		
		private var _boolean:IBooleanData;
		
		function ToggleBooleanAction(boolean:IBooleanData=null){
			this.boolean = boolean;
		}
		
		public function triggerAction(scopeDisplay:IDisplayObject):void{
			_boolean.booleanValue = !_boolean.booleanValue;
		}
	}
}