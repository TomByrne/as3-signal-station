package org.tbyrne.input.items
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.controls.ControlData;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.expressions.ParameterisedExpression;
	import org.tbyrne.data.operators.StringProxy;
	import org.tbyrne.actInfo.IKeyActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.input.shortcuts.ShortcutLiterator;
	import org.tbyrne.input.shortcuts.ShortcutType;

	public class AbstractInputItem extends ControlData
	{
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			if(!_scopeChanged)_scopeChanged = new Act();
			return _scopeChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get shownInMenuChanged():IAct{
			return (_shownInMenuChanged || (_shownInMenuChanged = new Act()));
		}
		/**
		 * @inheritDoc
		 */
		public function get menuLocationChanged():IAct{
			return (_menuLocationChanged || (_menuLocationChanged = new Act()));
		}
		
		protected var _menuLocationChanged:Act;
		protected var _shownInMenuChanged:Act;
		protected var _scopeChanged:Act;
		
		
		
		override public function set stringValue(value:IStringProvider):void{
			super.stringValue = value;
			_stringProxy.setParamProvider(value,1);
		}
		override public function get stringValue():IStringProvider{
			return _stringProxy;
		}
		
		
		
		public function get scopedObject():IScopedObject{
			return _scopedObject;
		}
		public function set scopedObject(value:IScopedObject):void{
			if(_scopedObject!=value){
				if(_scopedObject){
					_scopedObject.scopeChanged.removeHandler(onScopeChanged);
				}
				_scopedObject = value;
				if(_scopedObject){
					_scopedObject.scopeChanged.addHandler(onScopeChanged);
				}
			}
		}
		public function set scope(value:IDisplayObject):void{
			_scopedObject.scope = value;
		}
		public function get scope():IDisplayObject{
			return _scopedObject?_scopedObject.scope:null;
		}
		
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
				if(_isActiveProvider){
					_isActiveProvider.booleanValueChanged.removeHandler(onBooleanChanged);
				}
				_isActiveProvider = value;
				if(_isActiveProvider){
					_isActive = _isActiveProvider.booleanValue;
					_isActiveProvider.booleanValueChanged.addHandler(onBooleanChanged);
				}
			}
		}
		
		public function get shortcutType():String{
			return _shortcutType;
		}
		public function set shortcutType(value:String):void{
			_shortcutType = value;
		}
		public function get blockAscendantShortcuts():Boolean{
			return _blockAscendantShortcuts;
		}
		public function set blockAscendantShortcuts(value:Boolean):void{
			_blockAscendantShortcuts = value;
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
		
		public function get shownInMenu():Boolean{
			return _shownInMenu;
		}
		public function set shownInMenu(value:Boolean):void{
			if(_shownInMenu!=value){
				_shownInMenu = value;
				if(_shownInMenuChanged)_shownInMenuChanged.perform(this);
			}
		}
		public function get menuLocation():String{
			return _menuLocation;
		}
		public function set menuLocation(value:String):void{
			if(_menuLocation!=value){
				_menuLocation = value;
				if(_menuLocationChanged)_menuLocationChanged.perform(this);
			}
		}
		
		public function get keyCode():int{
			return _keyCode;
		}
		public function set keyCode(value:int):void{
			if(_keyCode!=value){
				_keyCode = value;
				validateShortcutStr();
			}
		}
		
		public function get charCode():int{
			return _charCode;
		}
		public function set charCode(value:int):void{
			if(_charCode!=value){
				_charCode = value;
				validateShortcutStr();
			}
		}
		
		public function get keyLocation():int{
			return _keyLocation;
		}
		public function set keyLocation(value:int):void{
			if(_keyLocation!=value){
				_keyLocation = value;
				validateShortcutStr();
			}
		}
		
		public function get shiftKey():Boolean{
			return _shiftKey;
		}
		public function set shiftKey(value:Boolean):void{
			if(_shiftKey!=value){
				_shiftKey = value;
				validateShortcutStr();
			}
		}
		
		public function get ctrlKey():Boolean{
			return _ctrlKey;
		}
		public function set ctrlKey(value:Boolean):void{
			if(_ctrlKey!=value){
				_ctrlKey = value;
				validateShortcutStr();
			}
		}
		
		public function get altKey():Boolean{
			return _altKey;
		}
		public function set altKey(value:Boolean):void{
			if(_altKey!=value){
				_altKey = value;
				validateShortcutStr();
			}
		}
		
		private var _altKey:Boolean;
		private var _ctrlKey:Boolean;
		private var _shiftKey:Boolean;
		private var _keyLocation:int = -1;
		private var _charCode:int = -1;
		private var _keyCode:int = -1;
		
		
		private var _menuLocation:String;
		private var _shownInMenu:Boolean = true;
		private var _scopedObject:IScopedObject;
		
		private var _blockAscendantShortcuts:Boolean = true;
		private var _shortcutType:String = ShortcutType.ON_UP;
		private var _scopeDisplay:IDisplayObject;
		private var _isActiveProvider:IBooleanProvider;
		private var _isActive:Boolean = true;
		
		public var _stringProxy:ParameterisedExpression;
		public var _shortcut:StringData;
		
		public function AbstractInputItem(stringProvider:IStringProvider=null, scopedObject:IScopedObject=null){
			_stringProxy = new ParameterisedExpression(createString,1);
			super(stringProvider);
			this.scopedObject = scopedObject;
		}
		private function createString(label:String, shortcut:String):String{
			if(label){
				if(shortcut){
					return label+" "+shortcut;
				}else{
					return label;
				}
			}else if(shortcut){
				return shortcut;
			}
			return null;
		}
		
		protected function onScopeChanged(scopedObject:IScopedObject, oldScope:IDisplayObject):void{
			if(_scopeChanged)_scopeChanged.perform(this,oldScope);
		}
		
		public function attemptExecute(keyEventInfo:IKeyActInfo, isDown:Boolean):Boolean{
			if(_isActive){
				if(hasShortcut() && checkKeyMatch(keyEventInfo)){
					if(isDown)executeKeyDown(keyEventInfo);
					else executeKeyUp(keyEventInfo);
				}
			}
			return false;
		}
		protected function hasShortcut():Boolean{
			return (keyCode!=-1 || charCode!=-1);
		}
		
		protected function checkKeyMatch(keyEventInfo:IKeyActInfo):Boolean{
			if(keyEventInfo.shiftKey==shiftKey && 
				keyEventInfo.ctrlKey==ctrlKey && 
				keyEventInfo.altKey==altKey && 
				(keyCode==-1 || keyEventInfo.keyCode==keyCode) && 
				(charCode==-1 || keyEventInfo.charCode==charCode) && 
				(keyLocation==-1 || keyEventInfo.keyLocation==keyLocation)){
				return true;
			}
			return false;
		}
		protected function executeKeyDown(keyEventInfo:IKeyActInfo):void{
			triggerAction(scope);
		}
		protected function executeKeyUp(keyEventInfo:IKeyActInfo):void{
			triggerAction(scope);
		}
		public function triggerAction(scopeDisplay:IDisplayObject):void{
			// override me
		}
		
		protected function onBooleanChanged(from:IBooleanProvider):void{
			_isActive = from.booleanValue;
		}
		
		private function validateShortcutStr():void{
			var shortcut:String = ShortcutLiterator.literateShortcut(this).toUpperCase();
			if(shortcut){
				_shortcut.stringValue = "("+shortcut+")";
				_stringProxy.setParamProvider(_shortcut,1);
				_stringProxy.paramCount = 2;
			}else{
				_stringProxy.clearParamProvider(1);
				_stringProxy.paramCount = 1;
			}
			
		}
	}
}