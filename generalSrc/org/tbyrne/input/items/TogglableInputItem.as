package org.tbyrne.input.items
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.input.menu.IMenuInputItem;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;

	public class TogglableInputItem extends AbstractInputItem implements IBooleanProvider, IBooleanConsumer, IShortcutInputItem, IMenuInputItem
	{
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			return (_booleanValueChanged || (_booleanValueChanged = new Act()));
		}
		protected var _booleanValueChanged:Act;
		
		
		
		
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
				assessString();
			}
		}
		override public function set stringValue(value:String):void{
			enabledString = value;
		}
		public function get enabledString():String{
			return _enabledString;
		}
		public function set enabledString(value:String):void{
			if(_enabledString!=value){
				_enabledString = value;
				assessString();
			}
		}
		public function get disabledString():String{
			return _disabledString;
		}
		public function set disabledString(value:String):void{
			if(_disabledString!=value){
				_disabledString = value;
				assessString();
			}
		}
		override public function get stringValue():String{
			return _stringValue;
		}
		
		private var _disabledString:String;
		private var _enabledString:String;
		private var _stringValue:String;
		
		
		private var _booleanValue:Boolean;
		
		public function TogglableInputItem(enabledString:String, disabledString:String=null){
			_enabledString = enabledString;
			_disabledString = disabledString;
			assessString();
		}
		protected function assessString():void{
			var newVal:String = ((_booleanValue || !_disabledString)?_enabledString:_disabledString);
			if(newVal!=_stringValue){
				_stringValue = newVal;
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
		}
		override public function triggerAction(scopeDisplay:IDisplayAsset):void{
			booleanValue = !booleanValue;
		}
	}
}