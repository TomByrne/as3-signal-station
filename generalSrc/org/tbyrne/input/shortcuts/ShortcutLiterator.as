package org.tbyrne.input.shortcuts
{
	import flash.system.Capabilities;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import org.tbyrne.input.items.AbstractInputItem;

	public class ShortcutLiterator
	{
		private static var KEY_CODE_LABELS:Dictionary;
		{
			KEY_CODE_LABELS = new Dictionary();
			KEY_CODE_LABELS[Keyboard.BACKSPACE] = "Backspace";
			KEY_CODE_LABELS[Keyboard.CAPS_LOCK] = "Caps Lock";
			KEY_CODE_LABELS[Keyboard.CONTROL] = "Ctrl";
			KEY_CODE_LABELS[Keyboard.DELETE] = "Delete";
			KEY_CODE_LABELS[Keyboard.DOWN] = "Down";
			KEY_CODE_LABELS[Keyboard.END] = "End";
			KEY_CODE_LABELS[Keyboard.ENTER] = "Enter";
			KEY_CODE_LABELS[Keyboard.ESCAPE] = "Escape";
			KEY_CODE_LABELS[Keyboard.F1] = "F1";
			KEY_CODE_LABELS[Keyboard.F1] = "F1";
			KEY_CODE_LABELS[Keyboard.F3] = "F3";
			KEY_CODE_LABELS[Keyboard.F4] = "F3";
			KEY_CODE_LABELS[Keyboard.F5] = "F3";
			KEY_CODE_LABELS[Keyboard.F6] = "F6";
			KEY_CODE_LABELS[Keyboard.F7] = "F7";
			KEY_CODE_LABELS[Keyboard.F8] = "F8";
			KEY_CODE_LABELS[Keyboard.F9] = "F9";
			KEY_CODE_LABELS[Keyboard.F10] = "F10";
			KEY_CODE_LABELS[Keyboard.F11] = "F11";
			KEY_CODE_LABELS[Keyboard.F12] = "F12";
			KEY_CODE_LABELS[Keyboard.F13] = "F13";
			KEY_CODE_LABELS[Keyboard.F14] = "F14";
			KEY_CODE_LABELS[Keyboard.F15] = "F15";
			KEY_CODE_LABELS[Keyboard.HOME] = "Home";
			KEY_CODE_LABELS[Keyboard.INSERT] = "Insert";
			KEY_CODE_LABELS[Keyboard.LEFT] = "Left";
			KEY_CODE_LABELS[Keyboard.PAGE_DOWN] = "Page Down";
			KEY_CODE_LABELS[Keyboard.PAGE_UP] = "Page Up";
			KEY_CODE_LABELS[Keyboard.RIGHT] = "Right";
			KEY_CODE_LABELS[Keyboard.SHIFT] = "Shift";
			KEY_CODE_LABELS[Keyboard.SPACE] = "Space";
			KEY_CODE_LABELS[Keyboard.TAB] = "Tab";
			KEY_CODE_LABELS[Keyboard.UP] = "Up";
		}
		
		
		
		public static function literateShortcut(item:AbstractInputItem):String{
			var ret:String = "";
			if(item.charCode!=-1 || item.keyCode!=-1){
				if(item.altKey){
					ret += "Alt + ";
				}
				if(item.ctrlKey){
					if(Capabilities.os.indexOf("Mac")!=-1 || Capabilities.os.indexOf("iPhone")!=-1 || Capabilities.os.indexOf("iPad")!=-1){
						ret += "Cmd + ";
					}else{
						ret += "Ctrl + ";
					}
				}
				if(item.shiftKey){
					ret += "Shft + ";
				}
				if(item.keyLocation!=-1){
					switch(item.keyLocation){
						case KeyLocation.LEFT:
							ret += "Left ";
							break;
						case KeyLocation.RIGHT:
							ret += "Right ";
							break;
						case KeyLocation.NUM_PAD:
							ret += "NumPad ";
							break;
					}
				}
				if(item.charCode!=-1){
					ret += String.fromCharCode(item.charCode).toUpperCase()+" ";
				}
				if(item.keyCode!=-1){
					var keyStr:String = KEY_CODE_LABELS[item.keyCode];
					if(keyStr){
						ret += keyStr+" ";
					}
				}
			}
			return ret;
		}
	}
}