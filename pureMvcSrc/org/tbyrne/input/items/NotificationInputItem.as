package org.tbyrne.input.items
{
	import org.puremvc.as3.interfaces.INotifier;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.input.menu.IMenuInputItem;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;

	public class NotificationInputItem extends AbstractInputItem implements ITriggerableAction, IShortcutInputItem, IMenuInputItem
	{
		
		public function get notifier():INotifier{
			return _notifier;
		}
		public function set notifier(value:INotifier):void{
			_notifier = value;
		}
		
		public function get notification():String{
			return _notification;
		}
		public function set notification(value:String):void{
			_notification = value;
		}
		
		public function get noteBody():*{
			return _noteBody;
		}
		public function set noteBody(value:*):void{
			_noteBody = value;
		}
		
		private var _noteBody:*;
		private var _notification:String;
		private var _notifier:INotifier;
		
		public function NotificationInputItem(stringProvider:IStringProvider=null, notifier:INotifier=null, notification:String=null, noteBody:String=null)
		{
			super(stringProvider);
			this.notifier = notifier;
			this.notification = notification;
			this.noteBody = noteBody;
		}
		override public function triggerAction(scopeDisplay:IDisplayAsset):void{
			_notifier.sendNotification(_notification,_noteBody);
		}
	}
}