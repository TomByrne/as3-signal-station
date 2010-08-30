package org.farmcode.display.tabFocus
{
	import flash.events.Event;
	
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;

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
			_interactiveAsset.tabIndex = value;
		}
		override public function set tabEnabled(value:Boolean):void{
			_interactiveAsset.tabEnabled = value;
		}
		override public function get tabIndicesRequired():uint{
			return 1;
		}
		
		public function get interactiveAsset():IInteractiveObjectAsset{
			return _interactiveAsset;
		}
		public function set interactiveAsset(value:IInteractiveObjectAsset):void{
			if(_interactiveAsset!=value){
				if(_interactiveAsset){
					_interactiveAsset.focusIn.removeHandler(onFocusIn);
					_interactiveAsset.focusOut.removeHandler(onFocusOut);
					_interactiveAsset.addedToStage.removeHandler(onAddedToStage);
					_interactiveAsset.removedFromStage.removeHandler(onRemovedFromStage);
				}
				_interactiveAsset = value;
				if(_interactiveAsset){
					_interactiveAsset.focusIn.addHandler(onFocusIn);
					_interactiveAsset.focusOut.addHandler(onFocusOut);
					_interactiveAsset.addedToStage.addHandler(onAddedToStage);
					_interactiveAsset.removedFromStage.addHandler(onRemovedFromStage);
				}
			}
		}
		
		private var _interactiveAsset:IInteractiveObjectAsset;
		private var _focused:Boolean;
		
		public function InteractiveAssetFocusWrapper(interactiveAsset:IInteractiveObjectAsset=null){
			this.interactiveAsset = interactiveAsset;
		}
		public function onFocusIn(e:Event, from:IInteractiveObjectAsset):void{
			_focused = true;
			if(_focusIn)_focusIn.perform(this);
		}
		public function onFocusOut(e:Event, from:IInteractiveObjectAsset):void{
			_focused = false;
			if(_focusOut)_focusOut.perform(this);
		}
		public function onAddedToStage(from:IInteractiveObjectAsset):void{
			if(_focused)_interactiveAsset.stage.focus = _interactiveAsset;
		}
		public function onRemovedFromStage(from:IInteractiveObjectAsset):void{
			if(_interactiveAsset.stage.focus == _interactiveAsset)_interactiveAsset.stage.focus = null;
		}
	}
}