package org.farmcode.display.popup
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.actLibrary.core.IRevertableAct;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.display.transition.WipeTransition;

	public class PopupInfo extends AbstractPopupInfo implements IPopupInfo
	{
		public function get centreToStage():Boolean{
			return _centreToStage;
		}
		public function set centreToStage(value:Boolean):void{
			_centreToStage = value;
			assessCentre();
		}
		
		public function get focusActs():Array{
			return _focusActs;
		}
		public function set focusActs(value:Array):void{
			if(_focusActsPerformed)revertFocusActs();
			_focusActs = value;
			assessFocused();
		}
		override public function set popupDisplay(value:DisplayObject):void{
			if(_popupDisplay){
				_popupDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
				_popupDisplay.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			}
			super.popupDisplay = value;
			if(_popupDisplay){
				_popupDisplay.addEventListener(Event.ADDED_TO_STAGE, onAdded);
				_popupDisplay.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
				setStage(_popupDisplay.stage);
			}else{
				setStage(null);
			}
			assessFocused();
		}
		override public function set focusable(value:Boolean):void{
			super.focusable = value;
			assessFocused();
		}
		override public function set isFocused(value:Boolean):void{
			super.isFocused = value;
			assessFocused();
		}
		
		private var _focusActs:Array;
		private var _centreToStage:Boolean;
		private var _focusActsPerformed:Boolean;
		private var _lastStage:Stage;
		
		public function PopupInfo(popupDisplay:DisplayObject=null, isModal:Boolean=false){
			super(popupDisplay, isModal);
		}
		private function assessCentre():void{
			if(_centreToStage && _lastStage){
				var centreX:Number = _lastStage.stageWidth/2;
				var centreY:Number = _lastStage.stageHeight/2;
				var bounds:Rectangle = _popupDisplay.getBounds(_popupDisplay);
				centreX -= (bounds.left+bounds.right)/2;
				centreY -= (bounds.top+bounds.bottom)/2;
				_popupDisplay.x = centreX;
				_popupDisplay.y = centreY;
			}
		}
		private function assessFocused():void{
			if(_focusActs && _focusable && _lastStage){
				if(_focusActsPerformed){
					if(!_isFocused)revertFocusActs();
				}else if(_isFocused){
					performFocusActs();
				}
			}
		}
		private function revertFocusActs():void{
			_focusActsPerformed = false;
			for each(var act:IRevertableAct in _focusActs){
				if(act){
					var revert:IAct = act.revertAct;
					var uniAct:IUniversalAct = revert as IUniversalAct;
					if(uniAct){
						uniAct.scopeDisplay = _popupDisplay;
					}
					act.revertAct.perform();
					if(uniAct){
						uniAct.scopeDisplay = null;
					}
				}
			}
		}
		private function performFocusActs():void{
			_focusActsPerformed = true;
			for each(var act:IAct in _focusActs){
				if(act){
					var uniAct:IUniversalAct = act as IUniversalAct;
					if(uniAct){
						uniAct.scopeDisplay = _popupDisplay;
					}
					act.perform();
					if(uniAct){
						uniAct.scopeDisplay = null;
					}
				}
			}
		}
		private function onAdded(e:Event):void{
			setStage(_popupDisplay.stage);
			assessFocused();
		}
		private function onRemoved(e:Event):void{
			setStage(null);
			assessFocused();
		}
		private function setStage(value:Stage):void{
			if(_lastStage != value){
				if(_lastStage){
					_lastStage.removeEventListener(Event.RESIZE, onStageResize);
				}
				_lastStage = value;
				if(_lastStage){
					_lastStage.addEventListener(Event.RESIZE, onStageResize);
					assessCentre();
				}
			}
		}
		private function onStageResize(e:Event):void{
			assessCentre();
		}
	}
}