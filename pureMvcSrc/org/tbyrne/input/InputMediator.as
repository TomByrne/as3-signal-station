package org.tbyrne.input
{
	import flash.utils.Dictionary;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.tbyrne.collections.ICollection;
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.collections.linkedList.LinkedListConverter;
	import org.tbyrne.core.AbstractMediator;
	import org.tbyrne.core.SignalStationMediatorNames;
	import org.tbyrne.data.dataTypes.IDataProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.input.menu.IMenuInputItem;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;
	import org.tbyrne.mediatorTypes.IMenuMediator;
	import org.tbyrne.notifications.ApplicationNotifications;
	import org.tbyrne.shortcuts.IShortcutMediator;
	
	public class InputMediator extends AbstractMediator
	{
		protected var _menuMediator:IMenuMediator;
		protected var _shortcutMediator:IShortcutMediator;
		
		protected var _pendingMenuItems:LinkedList;
		protected var _pendingShortcuts:LinkedList;
		
		// IDataProvider > [IDataProvider]
		protected var _childLists:Dictionary = new Dictionary();
		
		// ICollection > IDataProvider
		protected var _collectionToProvider:Dictionary = new Dictionary();
		
		
		public function InputMediator(mediatorName:String=null, viewComponent:Object=null){
			super(mediatorName, viewComponent);
		}
		
		/*override public function onRegister():void{
			
		}*/
		override public function onRemove():void{
			_menuMediator = null;
			_shortcutMediator = null;
		}
		
		
		override public function listNotificationInterests():Array {
			return [InputNotifications.ADD_INPUTS,
				InputNotifications.REMOVE_INPUTS,
				ApplicationNotifications.START_UP];
		}
		
		override public function handleNotification(note:INotification):void {
			var item:*;
			var shortcutInput:IShortcutInputItem;
			var menuInput:IMenuInputItem;
			var iterator:IIterator;
			switch (note.getName()) {
				case ApplicationNotifications.START_UP:
					getMenuMediator();
					if(_menuMediator && _pendingMenuItems){
						iterator = _pendingMenuItems.getIterator();
						while(menuInput = iterator.next()){
							_menuMediator.addMenuItem(menuInput);
						}
						_pendingMenuItems = null;
					}
					getShortcutMediator();
					if(_shortcutMediator && _pendingShortcuts){
						iterator = _pendingShortcuts.getIterator();
						while(shortcutInput = iterator.next()){
							_shortcutMediator.addShortcut(shortcutInput);
						}
						_pendingShortcuts = null;
					}
					break;
				case InputNotifications.ADD_INPUTS:
					for each(item in note.getBody()){
						menuInput = (item as IMenuInputItem);
						if(menuInput){
							addMenuItem(menuInput);
							addChildData(menuInput);
						}else{
							shortcutInput = (item as IShortcutInputItem);
							if(shortcutInput){
								addShortcut(shortcutInput);
							}
						}
					}
					break;
				case InputNotifications.REMOVE_INPUTS:
					for each(item in note.getBody()){
						menuInput = (item as IMenuInputItem);
						if(menuInput){
							removeMenuItem(menuInput);
							removeChildData(menuInput);
						}else{
							shortcutInput = (item as IShortcutInputItem);
							if(shortcutInput){
								removeShortcut(shortcutInput);
							}
						}
					}
					break;
			}
			
		}
		
		private function addChildData(menuData:*):void{
			var dataProv:IDataProvider = (menuData as IDataProvider);
			if(dataProv){
				if(dataProv.data){
					var list:ICollection = (dataProv.data as ICollection);
					if(list){
						_collectionToProvider[list] = menuData;
						list.collectionChanged.addHandler(onCollectionChanged);
					}else{
						list = (LinkedListConverter.fromNativeCollection(dataProv.data))
					}
					
					var iterater:IIterator = list.getIterator();
					var item:IStringProvider;
					var children:Array = _childLists[dataProv];
					while(item = iterater.next()){
						if(!children){
							children = [];
							_childLists[dataProv] = children;
						}
						children.push(item);
						addChildData(item);
						
					}
				}
			}
			var shortcut:IShortcutInputItem = (menuData as IShortcutInputItem);
			if(shortcut)addShortcut(shortcut);
		}
		private function removeChildData(menuData:*):void{
			var dataProv:IDataProvider = (menuData as IDataProvider);
			if(dataProv){
				var list:ICollection = (dataProv.data as ICollection);
				if(list){
					delete _collectionToProvider[list];
					list.collectionChanged.removeHandler(onCollectionChanged);
				}
				
				var oldChildren:Array = _childLists[menuData];
				if(oldChildren){
					for each(var child:* in oldChildren){
						removeChildData(child);
					}
					delete _childLists[menuData];
				}
				
			}
			var shortcut:IShortcutInputItem = (menuData as IShortcutInputItem);
			if(shortcut)removeShortcut(shortcut);
		}
		protected function onCollectionChanged(from:ICollection, fromX:int, toX:int):void{
			var dataProvider:IStringProvider = _collectionToProvider[from];
			//@todo optimise this
			removeChildData(dataProvider);
			addChildData(dataProvider);
		}
		public function addMenuItem(menuItem:IMenuInputItem):void {
			getMenuMediator();
			if(_menuMediator){
				_menuMediator.addMenuItem(menuItem);
			}else{
				if(!_pendingMenuItems)_pendingMenuItems = new LinkedList();
				_pendingMenuItems.push(menuItem);
			}
		}
		public function removeMenuItem(menuItem:IMenuInputItem):void {
			getMenuMediator();
			if(_menuMediator){
				_menuMediator.removeMenuItem(menuItem);
			}
			if(_pendingMenuItems)_pendingMenuItems.removeFirst(menuItem);
		}
		public function addShortcut(shortcut:IShortcutInputItem):void {
			getShortcutMediator();
			if(_shortcutMediator){
				_shortcutMediator.addShortcut(shortcut);
			}else{
				if(!_pendingShortcuts)_pendingShortcuts = new LinkedList();
				_pendingShortcuts.push(shortcut);
			}
		}
		public function removeShortcut(shortcut:IShortcutInputItem):void {
			getShortcutMediator();
			if(_shortcutMediator){
				_shortcutMediator.removeShortcut(shortcut);
			}
			if(_pendingShortcuts)_pendingShortcuts.removeFirst(shortcut);
		}
			
		
		public function getMenuMediator():IMenuMediator {
			if(!_menuMediator){
				_menuMediator = facade.retrieveMediator(SignalStationMediatorNames.MENU) as IMenuMediator;
			}
			return _menuMediator;
		}
		public function getShortcutMediator():IShortcutMediator {
			if(!_shortcutMediator){
				_shortcutMediator = facade.retrieveMediator(SignalStationMediatorNames.SHORTCUT) as IShortcutMediator;
			}
			return _shortcutMediator;
		}
	}
}