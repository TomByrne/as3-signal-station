package org.farmcode.sodalityPlatformEngine.control.advice
{
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.ISnapFocusAdvice;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public class AbstractFocusItemsAdvice extends Advice implements ISnapFocusAdvice, IRevertableAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get focusItems():Array{
			return _focusItems;
		}
		public function set focusItems(value:Array):void{
			//if(_focusItems != value){
				_focusItems = value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get doSnapFocus():Boolean{
			return _doSnapFocus;
		}
		public function set doSnapFocus(value:Boolean):void{
			//if(_doSnapFocus != value){
				_doSnapFocus = value;
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
		
		private var _doSnapFocus:Boolean;
		private var _focusItems:Array;
		
		public function AbstractFocusItemsAdvice(focusItems:Array=null, doSnapFocus:Boolean = false){
			super(abortable);
			this.focusItems = focusItems;
			this.doSnapFocus = doSnapFocus;
		}
		
	}
}