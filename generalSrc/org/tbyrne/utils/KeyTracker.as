package org.tbyrne.utils
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class KeyTracker
	{
		
		private static var _downKeys:Dictionary = new Dictionary();
		
		
		public static function init(stage:Stage):void{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}
		
		private static function handleKeyDown(evt:KeyboardEvent):void{
			_downKeys[evt.keyCode] = true;
		}
		
		private static function handleKeyUp(evt:KeyboardEvent):void{
			delete _downKeys[evt.keyCode];
		}
		
		public static function isKeyPressed(keyCode:int):Boolean{
			return _downKeys[keyCode];
		}
	}
}