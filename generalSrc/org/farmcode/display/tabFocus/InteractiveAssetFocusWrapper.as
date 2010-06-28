package org.farmcode.display.tabFocus
{
	import flash.events.Event;
	
	import org.farmcode.display.assets.IInteractiveObjectAsset;

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
		
		private var _interactiveAsset:IInteractiveObjectAsset;
		private var _focused:Boolean;
		
		public function InteractiveAssetFocusWrapper(interactiveObject:IInteractiveObjectAsset){
			_interactiveAsset = interactiveObject;
			_interactiveAsset.focusIn.addHandler(onFocusIn);
			_interactiveAsset.focusOut.addHandler(onFocusOut);
			_interactiveAsset.addedToStage.addHandler(onAddedToStage);
			_interactiveAsset.removedFromStage.addHandler(onRemovedFromStage);
		}
		public function onFocusIn(e:Event, from:IInteractiveObjectAsset):void{
			_focused = true;
			if(_focusIn)_focusIn.perform(this);
		}
		public function onFocusOut(e:Event, from:IInteractiveObjectAsset):void{
			_focused = false;
			if(_focusOut)_focusOut.perform(this);
		}
		public function onAddedToStage(e:Event, from:IInteractiveObjectAsset):void{
			if(_focused)_interactiveAsset.stage.focus = _interactiveAsset;
		}
		public function onRemovedFromStage(e:Event, from:IInteractiveObjectAsset):void{
			if(_interactiveAsset.stage.focus == _interactiveAsset)_interactiveAsset.stage.focus = null;
		}
	}
}