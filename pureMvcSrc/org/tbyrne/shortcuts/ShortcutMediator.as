package org.tbyrne.shortcuts
{
	import org.puremvc.as3.interfaces.INotification;
	import org.tbyrne.core.AbstractMediator;
	import org.tbyrne.core.SignalStationMediatorNames;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;
	import org.tbyrne.input.shortcuts.ShortcutManager;
	import org.tbyrne.mediatorTypes.IUIMediator;
	import org.tbyrne.notifications.ApplicationNotifications;
	
	public class ShortcutMediator extends AbstractMediator implements IShortcutMediator
	{
		protected var _manager:ShortcutManager;
		
		
		public function ShortcutMediator(){
			_manager = new ShortcutManager();
			super(SignalStationMediatorNames.SHORTCUT, _manager);
		}
		
		override public function onRegister():void{
			checkKeyListener();
		}
		
		private function checkKeyListener():void{
			var uiMediator:IUIMediator = facade.retrieveMediator(SignalStationMediatorNames.UI) as IUIMediator;
			_manager.keyDispatcher = uiMediator.mainUiDisplay as IInteractiveObject;
		}
		
		override public function onRemove():void{
			_manager.keyDispatcher = null;
		}
		
		
		override public function listNotificationInterests():Array {
			return [ApplicationNotifications.START_UP];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				case ApplicationNotifications.START_UP:
					checkKeyListener();
					break;
			}
		}
		public function addShortcut(shortcut:IShortcutInputItem):void{
			_manager.addShortcut(shortcut);
		}
		public function removeShortcut(shortcut:IShortcutInputItem):void{
			_manager.removeShortcut(shortcut);
		}
	}
}