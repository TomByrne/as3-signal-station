package org.tbyrne.data.controls
{
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	
	public class ControlData implements IControlData
	{
		
		public function get label():IStringProvider{
			return _label;
		}
		public function set label(value:IStringProvider):void{
			_label = value;
		}
		
		public function get active():IBooleanProvider{
			return _active;
		}
		public function set active(value:IBooleanProvider):void{
			_active = value;
		}
		
		public function get selected():IBooleanProvider{
			return _selected;
		}
		public function set selected(value:IBooleanProvider):void{
			_selected = value;
		}
		
		public function get numberValue():INumberProvider{
			return _numberValue;
		}
		public function set numberValue(value:INumberProvider):void{
			_numberValue = value;
		}
		
		public function get stringValue():IStringProvider{
			return _stringValue;
		}
		public function set stringValue(value:IStringProvider):void{
			_stringValue = value;
		}
		
		
		public function get selectedAction():ITriggerableAction{
			return _selectedAction;
		}
		public function set selectedAction(value:ITriggerableAction):void{
			_selectedAction = value;
		}
		
		public function get childData():*{
			return _childData;
		}
		public function set childData(value:*):void{
			_childData = value;
		}
		
		private var _childData:*;
		private var _selectedAction:ITriggerableAction;
		private var _stringValue:IStringProvider;
		private var _numberValue:INumberProvider;
		private var _selected:IBooleanProvider;
		private var _active:IBooleanProvider;
		private var _label:IStringProvider;
		
		
		public function ControlData(label:IStringProvider=null, selected:IBooleanProvider=null){
			this.label = label;
			this.selected = selected;
			
		}
	}
}