package org.tbyrne.data.navigation
{
	import org.puremvc.as3.interfaces.INotifier;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;

	public class NotificationNavItem extends StringData implements ITriggerableAction
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
		
		public function NotificationNavItem(stringValue:String=null, notifier:INotifier=null, notification:String=null, noteBody:String=null)
		{
			super(stringValue);
			this.notifier = notifier;
			this.notification = notification;
			this.noteBody = noteBody;
		}
		public function triggerAction(scopeDisplay:IDisplayAsset):void{
			_notifier.sendNotification(_notification,_noteBody);
		}
	}
}