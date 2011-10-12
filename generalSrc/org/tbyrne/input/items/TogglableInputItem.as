package org.tbyrne.input.items
{
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IBooleanData;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.input.menu.IMenuInputItem;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;

	public class TogglableInputItem extends AbstractInputItem implements IShortcutInputItem, IMenuInputItem
	{
		override public function set stringValue(value:IStringProvider):void{
			enabledString = value;
		}
		public function get enabledString():IStringProvider{
			return _enabledString;
		}
		public function set enabledString(value:IStringProvider):void{
			if(_enabledString!=value){
				if(_enabledString){
					_enabledString.stringValueChanged.removeHandler(onStringChanged);
				}
				_enabledString = value;
				if(_enabledString){
					_enabledString.stringValueChanged.addHandler(onStringChanged);
				}
				assessString();
			}
		}
		public function get disabledString():IStringProvider{
			return _disabledString;
		}
		public function set disabledString(value:IStringProvider):void{
			if(_disabledString!=value){
				if(_disabledString){
					_disabledString.stringValueChanged.removeHandler(onStringChanged);
				}
				_disabledString = value;
				if(_disabledString){
					_disabledString.stringValueChanged.addHandler(onStringChanged);
				}
				assessString();
			}
		}
		
		private var _disabledString:IStringProvider;
		private var _enabledString:IStringProvider;
		
		private var _selectedData:BooleanData;
		
		private var _booleanValue:Boolean;
		
		public function TogglableInputItem(enabledString:IStringProvider, disabledString:IStringProvider=null){
			_selectedData = new BooleanData();
			_selectedData.booleanValueChanged.addHandler(onSelectedChanged);
			selected = _selectedData;
			
			this.enabledString = enabledString;
			this.disabledString = disabledString;
			assessString();
		}
		
		private function onSelectedChanged(from:IBooleanData):void{
			assessString();
		}
		private function onStringChanged(from:IStringProvider):void{
			assessString();
		}
		protected function assessString():void{
			var newVal:String = ((selected.booleanValue || !_disabledString)?(_enabledString?_enabledString.stringValue:null):_disabledString.stringValue);
			if(!_stringValue || newVal!=_stringValue.stringValue){
				super.stringValue = new StringData(newVal);
			}
		}
		override public function triggerAction(scopeDisplay:IDisplayObject):void{
			_selectedData.booleanValue = !_selectedData.booleanValue;
		}
	}
}