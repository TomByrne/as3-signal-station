package org.farmcode.display.popup
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import org.farmcode.actLibrary.display.popup.IModalDisablerView;

	public class AbstractPopupInfo implements IPopupInfo
	{
		
		public function get popupDisplay():DisplayObject{
			return _popupDisplay;
		}
		public function set popupDisplay(value:DisplayObject):void{
			_popupDisplay = value;
		}
		
		public function get isModal():Boolean{
			return _isModal;
		}
		public function set isModal(value:Boolean):void{
			_isModal = value;
		}
		
		
		public function get modalDisabler():IModalDisablerView{
			return _modalDisabler;
		}
		public function set modalDisabler(value:IModalDisablerView):void{
			_modalDisabler = value;
		}
		
		public function get focusable():Boolean{
			return _focusable;
		}
		public function set focusable(value:Boolean):void{
			_focusable = value;
		}
		public function get isFocused():Boolean{
			return _isFocused;
		}
		public function set isFocused(value:Boolean):void{
			_isFocused = value;
		}
		
		protected var _focusable:Boolean;
		protected var _isFocused:Boolean;
		
		private var _modalDisabler:IModalDisablerView;
		private var _isModal:Boolean;
		
		protected var _popupDisplay:DisplayObject;
		
		public function AbstractPopupInfo(popupDisplay:DisplayObject=null, isModal:Boolean=false){
			this.popupDisplay = popupDisplay;
			this.isModal = isModal;
		}
	}
}