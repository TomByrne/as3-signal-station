package org.tbyrne.input.shortcuts
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.binding.PropertyWatcher;
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.core.IApplication;
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.display.assets.utils.isDescendant;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.IScopedObjectRoot;
	import org.tbyrne.display.core.ScopedObjectAssigner;
	import org.tbyrne.display.core.ScopedObjectTree;
	import org.tbyrne.utils.methodClosure;

	public class ShortcutManager implements IScopedObjectRoot
	{
		protected static var _managers:Dictionary = new Dictionary();
		protected static var _scopedObjectAssigner:ScopedObjectAssigner = new ScopedObjectAssigner();
		
		public static function addShortcutManager(keyDispatcher:IInteractiveObject):ShortcutManager{
			var manager:ShortcutManager = new ShortcutManager(keyDispatcher);
			_managers[keyDispatcher] = manager;
			_scopedObjectAssigner.addManager(manager);
			return manager;
		}
		public static function removeShortcutManager(keyDispatcher:IInteractiveObject):void{
			var manager:ShortcutManager = _managers[keyDispatcher];
			_scopedObjectAssigner.removeManager(manager);
			delete _managers[keyDispatcher];
			manager.keyDispatcher = null;
		}
		public static function addShortcut(shortcut:IShortcutInputItem):void{
			_scopedObjectAssigner.addScopedObject(shortcut);
		}
		public static function removeShortcut(shortcut:IShortcutInputItem):void{
			_scopedObjectAssigner.removeScopedObject(shortcut);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			return (_scopeChanged || (_scopeChanged = new Act()));
		}
		
		protected var _scopeChanged:Act;
		
		
		public function get scope():IDisplayObject{
			return keyDispatcher;
		}
		public function set scope(value:IDisplayObject):void{
			keyDispatcher = (value as IInteractiveObject);
		}
		public function get keyDispatcher():IInteractiveObject{
			return _keyDispatcher;
		}
		public function set keyDispatcher(value:IInteractiveObject):void{
			if(_keyDispatcher!=value){
				/*if(_keyDispatcher){
					_keyDispatcher.keyDown.removeHandler(onKeyDown);
					_keyDispatcher.keyUp.removeHandler(onKeyUp);
				}*/
				_keyDispatcher = value;
				_keyDispatcherCont = (value as IDisplayObjectContainer);
				/*if(_keyDispatcher){
					_keyDispatcher.keyDown.addHandler(onKeyDown);
					_keyDispatcher.keyUp.addHandler(onKeyUp);
				}*/
				_stageWatcher.bindable = value;
				if(_scopeChanged)_scopeChanged.perform(this);
			}
		}
		
		protected var _keyDispatcher:IInteractiveObject;
		protected var _keyDispatcherCont:IDisplayObjectContainer;
		//protected var _shortcuts:LinkedList;
		protected var _shortcutTree:ScopedObjectTree;
		protected var _capturingShortcuts:Dictionary;
		protected var _downKeys:Dictionary = new Dictionary();
		protected var _stageWatcher:PropertyWatcher;
		
		public function ShortcutManager(keyDispatcher:IInteractiveObject=null){
			_stageWatcher = new PropertyWatcher("stage",setStage,null,unsetStage);
			_capturingShortcuts = new Dictionary();
			this.keyDispatcher = keyDispatcher;
			_shortcutTree = new ScopedObjectTree();
		}
		protected function setStage(stage:IStage):void{
			stage.keyDown.addHandler(onKeyDown);
			stage.keyUp.addHandler(onKeyUp);
		}
		protected function unsetStage(stage:IStage):void{
			stage.keyDown.removeHandler(onKeyDown);
			stage.keyUp.removeHandler(onKeyUp);
		}
		protected function onKeyDown(from:IInteractiveObject, info:IKeyActInfo):void{
			if(_downKeys[info.keyCode]){
				executeShortcuts(info, true, true);
			}else{
				_downKeys[info.keyCode] = info;
				executeShortcuts(info, true, false);
			}
		}
		protected function onKeyUp(from:IInteractiveObject, info:IKeyActInfo):void{
			if(_capturingShortcuts[info.keyCode]){
				executeShortcuts(info, false, true);
			}else{
				executeShortcuts(info, false, false);
			}
			delete _downKeys[info.keyCode];
		}
		protected function executeShortcuts(info:IKeyActInfo, isDown:Boolean, isHolding:Boolean):void{
			if(isHolding || _keyDispatcherCont==info.keyTarget || (_keyDispatcherCont && isDescendant(_keyDispatcherCont,info.keyTarget))){
				_shortcutTree.executeUpwardsFrom(info.keyTarget,methodClosure(match,info,isDown,isHolding));
			}
		}
		protected function match(shortcut:IShortcutInputItem, forDisplay:IDisplayObject, info:IKeyActInfo, isDown:Boolean, isHolding:Boolean):Boolean{
			var typeMatched:Boolean = false;
			var isDuringHold:Boolean = false;
			switch(shortcut.shortcutType){
				case ShortcutType.DURING_HOLD:
					if(isDown || isHolding){
						typeMatched = true;
						isDuringHold = true;
					}
					break;
				case ShortcutType.ON_DOWN:
					if(isDown && !isHolding){
						typeMatched = true;
					}
					break;
				case ShortcutType.ON_UP:
					if(!isDown && !isHolding){
						typeMatched = true;
					}
					break;
			}
			if(typeMatched){
				if(shortcut.attemptExecute(info,isDown)){
					if(isDuringHold){
						if(!isDown){
							delete _capturingShortcuts[info.keyCode];
						}else if(!isHolding){
							_capturingShortcuts[info.keyCode] = true;
						}
					}
					return !shortcut.blockAscendantShortcuts;
				}
			}
			return true;
		}
		public function addShortcut(shortcut:IShortcutInputItem):void{
			addDescendant(shortcut);
		}
		public function removeShortcut(shortcut:IShortcutInputItem):void{
			removeDescendant(shortcut);
		}
		public function addDescendant(descendant:IScopedObject):void{
			_shortcutTree.addScopedObject(descendant);
		}
		public function removeDescendant(descendant:IScopedObject):void{
			_shortcutTree.removeScopedObject(descendant);
		}
	}
}