package org.tbyrne.shortcuts
{
	import org.puremvc.as3.interfaces.INotification;
	import org.tbyrne.core.AbstractMediator;
	
	public class ShortcutMediator extends AbstractMediator
	{
		private static const NAME:String = "ShortcutMediator";
		
		
		public function ShortcutMediator(){
			super(NAME, null);
		}
		override public function listNotificationInterests():Array {
			return [ShortcutNotifications.ADD_SHORTCUT];
		}
		
		override public function handleNotification(note:INotification):void {
			var featureColl:FeaturesCollection;
			
			switch (note.getName()) {
				case ShortcutNotifications.ADD_SHORTCUT:
					ShortcutManager.addShortcut(note.getBody() as IShortcutInfo);
					break;
				case ShortcutNotifications.REMOVE_SHORTCUT:
					ShortcutManager.removeShortcut(note.getBody() as IShortcutInfo);
					break;
			}
		}
	}
}