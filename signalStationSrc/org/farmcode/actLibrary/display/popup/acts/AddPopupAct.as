package org.farmcode.actLibrary.display.popup.acts
{
	import flash.display.DisplayObjectContainer;
	
	import org.farmcode.actLibrary.core.IRevertableAct;
	import org.farmcode.actLibrary.display.popup.actTypes.IAddPopupAct;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.popup.IPopupInfo;
	
	
	public class AddPopupAct extends AbstractPopupAct implements IAddPopupAct, IRevertableAct
	{
		public function AddPopupAct(popupInfo:IPopupInfo=null, parent:DisplayObjectContainer=null){
			super(popupInfo);
			this.parent = parent;
		}
		
		public function get parent():DisplayObjectContainer{
			return _parent;
		}
		public function set parent(value:DisplayObjectContainer):void{
			_parent = value;
		}
		
		private var _parent:DisplayObjectContainer;
		private var _doRevert: Boolean = true;
		
		public function get doRevert(): Boolean{
			return this._doRevert;
		}
		public function set doRevert(value: Boolean): void{
			this._doRevert = value;
		}
		public function get revertAct():IAct{
			return new RemovePopupAct(popupInfo);
		}
	}
}