package org.farmcode.sodalityLibrary.display.popUp.advice
{
	import flash.display.DisplayObject;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.display.popUp.adviceTypes.IAddPopUpAdvice;
	
	public class AddPopUpAdvice extends AbstractPopUpAdvice implements IAddPopUpAdvice
	{
		
		public function AddPopUpAdvice(displayPath:String=null, display:DisplayObject=null, modal: Boolean = false){
			super(displayPath, display);
			this.modal = modal;
		}
		
		private var _doRevert: Boolean = true;
		private var _modal:Boolean;
		
		[Property(clonable="true")]
		public function get doRevert(): Boolean{
			return this._doRevert;
		}
		public function set doRevert(value: Boolean): void{
			this._doRevert = value;
		}
		[Property(toString="true",clonable="true")]
		public function get modal():Boolean{
			return _modal;
		}
		public function set modal(value:Boolean):void{
			if(value!=_modal){
				_modal = value;
			}
		}
		public function get revertAdvice(): Advice{
			return new RemovePopUpAdvice(_displayPath,display);
		}
	}
}