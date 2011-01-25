package org.tbyrne.actLibrary.display.popup.acts
{
	import org.tbyrne.actLibrary.core.IRevertableAct;
	import org.tbyrne.actLibrary.display.popup.actTypes.IAddPopupAct;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.popup.IPopupInfo;
	
	
	public class AddPopupAct extends AbstractPopupAct implements IAddPopupAct, IRevertableAct
	{
		public function AddPopupAct(popupInfo:IPopupInfo=null, parent:IDisplayObjectContainer=null){
			super(popupInfo);
			this.parent = parent;
		}
		
		public function get parent():IDisplayObjectContainer{
			return _parent;
		}
		public function set parent(value:IDisplayObjectContainer):void{
			_parent = value;
		}
		
		private var _parent:IDisplayObjectContainer;
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