package org.tbyrne.shortcuts.types
{
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.ProxyScopedObject;
	import org.tbyrne.shortcuts.IShortcutInfo;
	
	public class AbstractShortcutInfo extends ProxyScopedObject implements IShortcutInfo
	{
		
		public function get isActive():Boolean{
			return _isActive;
		}
		public function set isActive(value:Boolean):void{
			if(_isActive!=value){
				isActiveProvider = null;
				_isActive = value;
			}
		}
		
		public function get isActiveProvider():IBooleanProvider{
			return _isActiveProvider;
		}
		public function set isActiveProvider(value:IBooleanProvider):void{
			if(_isActiveProvider!=value){
				_isActiveProvider = value;
				if(_isActiveProvider){
					_isActive = _isActiveProvider.booleanValue;
				}
			}
		}
		
		public function get shortcutType():String{
			return _shortcutType;
		}
		public function set shortcutType(value:String):void{
			_shortcutType = value;
		}
		
		
		public function get character():String{
			if(charCode==-1){
				return null;
			}else{
				return String.fromCharCode(charCode);
			}
		}
		public function set character(value:String):void{
			charCode = value.charCodeAt(0);
		}
		
		private var _shortcutType:String;
		private var _scopeDisplay:IDisplayAsset;
		private var _isActiveProvider:IBooleanProvider;
		private var _isActive:Boolean;
		
		public var shiftKey:Boolean;
		public var ctrlKey:Boolean;
		public var altKey:Boolean;
		
		public var keyCode:int = -1;
		public var charCode:int = -1;
		public var keyLocation:int = -1;
		
		public function AbstractShortcutInfo()
		{
		}
		
		public function attemptExecute(keyEventInfo:IKeyEventInfo):Boolean{
			return false;
		}
	}
}