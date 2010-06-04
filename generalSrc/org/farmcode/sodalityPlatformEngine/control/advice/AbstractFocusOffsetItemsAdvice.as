package org.farmcode.sodalityPlatformEngine.control.advice
{
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public class AbstractFocusOffsetItemsAdvice extends Advice implements IRevertableAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get focusItem():IFocusItem{
			return _focusItem;
		}
		public function set focusItem(value:IFocusItem):void{
			//if(_focusItem != value){
				_focusItem = value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get focusOffsetItems():Array{
			return _focusOffsetItems;
		}
		public function set focusOffsetItems(value:Array):void{
			//if(_focusOffsetItems != value){
				_focusOffsetItems = value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get doRevert():Boolean{
			return _doRevert;
		}
		public function set doRevert(value:Boolean):void{
			//if(_doRevert != value){
				_doRevert = value;
			//}
		}
		public function get revertAdvice():Advice{
			return null;
		}
		
		private var _doRevert:Boolean = false;
		
		private var _focusOffsetItems:Array;
		private var _focusItem:IFocusItem;
		
		public function AbstractFocusOffsetItemsAdvice(focusItem:IFocusItem=null, focusOffsetItems:Array=null){
			super(abortable);
			this.focusItem = focusItem;
			this.focusOffsetItems = focusOffsetItems;
		}
		
	}
}