package org.tbyrne.display.tabFocus
{
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.IStage;

	public class InteractiveAssetFocusWrapper extends AbstractTabFocusable implements ITabFocusable
	{
		override public function get focused():Boolean{
			return _focused;
		}
		override public function set focused(value:Boolean):void{
			if(_focused!=value){
				_focused = value;
				if(_interactiveAsset.stage){
					if(value)_interactiveAsset.stage.focus = _interactiveAsset;
					else if(_interactiveAsset.stage.focus == _interactiveAsset)_interactiveAsset.stage.focus = null;
				}
			}
		}
		override public function set tabIndex(value:int):void{
			_tabIndex = value;
			if(_interactiveAsset)_interactiveAsset.tabIndex = value;
		}
		override public function set tabEnabled(value:Boolean):void{
			_tabEnabled = value;
			if(_interactiveAsset)_interactiveAsset.tabEnabled = value;
		}
		override public function get tabIndicesRequired():uint{
			return 1;
		}
		
		public function get interactiveAsset():IInteractiveObject{
			return _interactiveAsset;
		}
		public function set interactiveAsset(value:IInteractiveObject):void{
			if(_interactiveAsset!=value){
				if(_interactiveAsset){
					_interactiveAsset.focusIn.removeHandler(onFocusIn);
					_interactiveAsset.focusOut.removeHandler(onFocusOut);
					_interactiveAsset.addedToStage.removeHandler(onAddedToStage);
					_interactiveAsset.removedFromStage.removeHandler(onRemovedFromStage);
					if(_lastStage)onRemovedFromStage()
				}
				_interactiveAsset = value;
				if(_interactiveAsset){
					_interactiveAsset.tabEnabled = _tabEnabled;
					_interactiveAsset.tabIndex = _tabIndex;
					_interactiveAsset.focusIn.addHandler(onFocusIn);
					_interactiveAsset.focusOut.addHandler(onFocusOut);
					_interactiveAsset.addedToStage.addHandler(onAddedToStage);
					_interactiveAsset.removedFromStage.addHandler(onRemovedFromStage);
					if(_interactiveAsset.stage)onAddedToStage();
				}
			}
		}
		
		private var _interactiveAsset:IInteractiveObject;
		private var _focused:Boolean;
		private var _lastStage:IStage;

		private var _tabIndex:int;
		private var _tabEnabled:Boolean = true;
		
		public function InteractiveAssetFocusWrapper(interactiveAsset:IInteractiveObject=null){
			this.interactiveAsset = interactiveAsset;
		}
		public function onFocusIn(from:IInteractiveObject):void{
			_focused = true;
			if(_focusIn)_focusIn.perform(this);
		}
		public function onFocusOut(from:IInteractiveObject):void{
			_focused = false;
			if(_focusOut)_focusOut.perform(this);
		}
		public function onAddedToStage(from:IInteractiveObject=null):void{
			_lastStage = _interactiveAsset.stage;
			if(_focused)_lastStage.focus = _interactiveAsset;
		}
		public function onRemovedFromStage(from:IInteractiveObject=null):void{
			if(_lastStage.focus == _interactiveAsset)_lastStage.focus = null;
			_lastStage = null;
		}
	}
}