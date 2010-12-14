package org.tbyrne.shortcuts
{
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.core.IApplication;
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.IScopedObjectRoot;
	import org.tbyrne.display.core.ScopedObjectAssigner;
	import org.tbyrne.display.validation.ScopedObjectTree;

	public class ShortcutManager implements IScopedObjectRoot
	{
		protected static var _scopedObjectAssigner:ScopedObjectAssigner = new ScopedObjectAssigner();
		
		public static function addShortcutManager(keyDispatcher:IInteractiveObjectAsset):IApplication{
			var manager:ShortcutManager = new ShortcutManager(keyDispatcher);
			_managers[keyDispatcher] = manager;
			_scopedObjectAssigner.addManager(manager);
			return manager;
		}
		public static function removeApplication(keyDispatcher:IInteractiveObjectAsset):void{
			var manager:ShortcutManager = _managers[keyDispatcher];
			_scopedObjectAssigner.removeManager(manager);
			delete _managers[keyDispatcher];
			manager.application = null;
		}
		public static function addShortcut(shortcut:IShortcutInfo):void{
			_scopedObjectAssigner.addScopedObject(shortcut);
		}
		public static function removeShortcut(shortcut:IShortcutInfo):void{
			_scopedObjectAssigner.removeScopedObject(shortcut);
		}
		
		
		protected var _keyDispatcher:IInteractiveObjectAsset;
		protected var _shortcuts:LinkedList;
		protected var _shortcutTree:ScopedObjectTree;
		protected var _capturingShortcut:IShortcutInfo;
		
		public function ShortcutManager(keyDispatcher:IInteractiveObjectAsset){
			_keyDispatcher = keyDispatcher;
			_keyDispatcher.keyDown.addHandler(onKeyDown);
			_keyDispatcher.keyUp.addHandler(onKeyUp);
		}
		protected function onKeyDown(from:IInteractiveObjectAsset, info:IKeyActInfo):void{
			
		}
		protected function onKeyUp(from:IInteractiveObjectAsset, info:IKeyActInfo):void{
			if(_capturingShortcut){
				
			}else{
				
			}
		}
		public function addDescendant(descendant:IScopedObject):void{
			_shortcutTree.addScopedObject(descendant);
		}
		public function removeDescendant(descendant:IScopedObject):void{
			_shortcutTree.removeScopedObject(descendant);
		}
	}
}