package org.farmcode.sodalityPlatformEngine.control
{
	import au.com.thefarmdigital.parallax.Parallax;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.control.members.ProxyPropertyMember;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IAddFocusItemsAdvice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IAddFocusOffsetItemsAdvice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IRemoveFocusItemsAdvice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IRemoveFocusOffsetItemsAdvice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.ISnapFocusAdvice;
	import org.farmcode.sodalityPlatformEngine.control.focusController.FocusController;
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusOffsetItem;
	import org.farmcode.sodalityPlatformEngine.core.advice.RequestApplicationSizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationResizeAdvice;
	import org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes.IFocusOnSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;
	
	import flash.events.Event;

	public class PlatformControllable extends DynamicAdvisor implements IPlatformControllable
	{
		public function get parallax():Parallax{
			return _parallax;
		}
		public function set parallax(value:Parallax):void{
			if(value!=_parallax){
				_parallax = value;
				_cameraXControl.subject = _parallax.camera;
				_cameraYControl.subject = _parallax.camera;
				_cameraZControl.subject = _parallax.camera;
				this._parallax.render();
			}
		}
		public function get focusController():FocusController{
			return _focusController;
		}
		override public function set addedToPresident(value:Boolean):void{
			super.addedToPresident = value;
			if(value && appSized){
				requestSize();
			}
		}
		
		public var appSized:Boolean = true;
		
		private var _cameraXControl:ProxyPropertyMember;
		private var _cameraYControl:ProxyPropertyMember;
		private var _cameraZControl:ProxyPropertyMember;
		
		private var _active: Boolean;
		private var _pendingSnap: Boolean;
		private var _parallax:Parallax;
		protected var _scene:IScene;
		
		private var _focusController:FocusController = new FocusController();
		
		public function PlatformControllable(parallax:Parallax=null){
			_cameraXControl = new ProxyPropertyMember(null,"x");
			_cameraYControl = new ProxyPropertyMember(null,"y");
			_cameraZControl = new ProxyPropertyMember(null,"z");
			this._parallax = parallax;
			
			_focusController.lazyFocusAssessment = true;
		}

		public function get cameraXControl():ProxyPropertyMember{
			return _cameraXControl;
		}
		public function get cameraYControl():ProxyPropertyMember{
			return _cameraYControl;
		}
		public function get cameraZControl():ProxyPropertyMember{
			return _cameraZControl;
		}
		protected function set active(value: Boolean): void{
			if (value != this.active){
				this._active = value;
				if(value){
					assessFocus();
				}
			}
		}
		protected function get active(): Boolean{
			return this._active;
		}
		
		private function requestSize():void{
			var requestSize:RequestApplicationSizeAdvice = new RequestApplicationSizeAdvice();
			requestSize.addEventListener(AdviceEvent.COMPLETE, onSizeRetrieved);
			dispatchEvent(requestSize);
		}
		private function onSizeRetrieved(e:AdviceEvent):void{
			var requestSize:RequestApplicationSizeAdvice = (e.target as RequestApplicationSizeAdvice);
			if(appSized){
				focusController.focusRange = requestSize.appBounds;
				assessFocus()
			}
		}
		protected function assessFocus():void{
			if(active){
				focusController.assessFocus();
				if(_pendingSnap){
					_pendingSnap = false;
					focusController.snapFocus();
				}
			}
		}
		
		// focus items
		[Trigger(triggerTiming="before")]
		public function onAddFocusItems(cause:IAddFocusItemsAdvice):void{
			cause.addEventListener(AdviceEvent.EXECUTE, addFocusItems);
		}
		protected function addFocusItems(e:AdviceEvent):void{
			var cause:IAddFocusItemsAdvice = (e.target as IAddFocusItemsAdvice);
			cause.removeEventListener(AdviceEvent.EXECUTE, addFocusItems);
			for each(var item:IFocusItem in cause.focusItems){
				focusController.addFocusItem(item);
			}
			assessFocus();
		}
		[Trigger(triggerTiming="before")]
		public function onRemoveFocusItems(cause:IRemoveFocusItemsAdvice):void{
			cause.addEventListener(AdviceEvent.EXECUTE, removeFocusItems);
		}
		protected function removeFocusItems(e:AdviceEvent):void{
			var cause:IRemoveFocusItemsAdvice = (e.target as IRemoveFocusItemsAdvice);
			cause.removeEventListener(AdviceEvent.EXECUTE, removeFocusItems);
			for each(var item:IFocusItem in cause.focusItems){
				focusController.removeFocusItem(item);
			}
			assessFocus();
		}
		[Trigger(triggerTiming="before")]
		public function onAddFocusOffsetItems(cause:IAddFocusOffsetItemsAdvice):void{
			cause.addEventListener(AdviceEvent.EXECUTE, addFocusOffsetItems);
		}
		protected function addFocusOffsetItems(e:AdviceEvent):void{
			var cause:IAddFocusOffsetItemsAdvice = (e.target as IAddFocusOffsetItemsAdvice);
			cause.removeEventListener(AdviceEvent.EXECUTE, addFocusOffsetItems);
			for each(var offsetItem:IFocusOffsetItem in cause.focusOffsetItems){
				focusController.addFocusOffsetItem(cause.focusItem, offsetItem);
			}
			assessFocus();
		}
		[Trigger(triggerTiming="before")]
		public function onRemoveFocusOffsetItems(cause:IRemoveFocusOffsetItemsAdvice):void{
			cause.addEventListener(AdviceEvent.EXECUTE, removeFocusOffsetItems);
		}
		protected function removeFocusOffsetItems(e:AdviceEvent):void{
			var cause:IRemoveFocusOffsetItemsAdvice = (e.target as IRemoveFocusOffsetItemsAdvice);
			cause.removeEventListener(AdviceEvent.EXECUTE, removeFocusOffsetItems);
			for each(var offsetItem:IFocusOffsetItem in cause.focusOffsetItems){
				focusController.removeFocusOffsetItem(cause.focusItem, offsetItem);
			}
			assessFocus();
		}
		
		
		[Trigger(triggerTiming="before")]
		public function onSnapFocus(cause:ISnapFocusAdvice):void{
			if(cause.doSnapFocus)focusController.snapFocus();
		}
		
		
		[Trigger(triggerTiming="after")]
		public function onAppResize(cause: IApplicationResizeAdvice):void{
			if(appSized){
				focusController.focusRange = cause.appBounds;
				assessFocus()
			}
		}
		[Trigger(triggerTiming="before")]
		public function onBeforeSceneChange(cause:IShowSceneAdvice):void{
			_pendingSnap = true;
			_scene = null;
		}
		[Trigger(triggerTiming="after")]
		public function onAfterSceneChange( cause:IShowSceneAdvice):void{
			if(cause.sceneDetails.scene){
				_scene = cause.sceneDetails.scene;
				focusController.focusBounds = _scene.cameraBounds;
			}else{
				_scene = null;
			}
		}
		[Trigger(triggerTiming="after")]
		public function onSceneFocus(cause:IFocusOnSceneAdvice):void{
			if(cause.performFocus){
				active = cause.focused;
			}
		}
	}
}