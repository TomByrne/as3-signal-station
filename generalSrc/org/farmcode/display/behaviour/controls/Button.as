package org.farmcode.display.behaviour.controls
{
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.utils.MovieClipUtils;
	
	public class Button extends Control
	{
		internal static var INACTIVE_FRAME_LABEL:String = "inactive";
		internal static var OVER_FRAME_LABEL:String = "mouseOver";
		internal static var OUT_FRAME_LABEL:String = "mouseOut";
		internal static var DOWN_FRAME_LABEL:String = "mouseDown";
		internal static var UP_FRAME_LABEL:String = "mouseUp";
		
		override public function set asset(value:DisplayObject) : void{
			super.asset = value;
			dispatchMeasurementChange();
		}
		
		/**
		 * handler(button:Button)
		 */
		public function get clickAct():IAct{
			if(!_clickAct)_clickAct = new Act();
			return _clickAct;
		}
		/**
		 * handler(button:Button)
		 */
		public function get mouseDownAct():IAct{
			if(!_mouseDownAct)_mouseDownAct = new Act();
			return _mouseDownAct;
		}
		/**
		 * handler(button:Button)
		 */
		public function get rollOverAct():IAct{
			if(!_rollOverAct)_rollOverAct = new Act();
			return _rollOverAct;
		}
		/**
		 * handler(button:Button)
		 */
		public function get rollOutAct():IAct{
			if(!_rollOutAct)_rollOutAct = new Act();
			return _rollOutAct;
		}
		/**
		 * handler(button:Button)
		 */
		public function get mouseUpAct():IAct{
			if(!_mouseUpAct)_mouseUpAct = new Act();
			return _mouseUpAct;
		}
		
		public function get over():Boolean{
			return _over;
		}
		public function get down():Boolean{
			return _down;
		}
		
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_active!=value){
				_active = value;
				if(!value){
					_over = false;
					_down = false;
				}
				if(_spriteAsset){
					_spriteAsset.buttonMode = _active;
				}
				assessLabel();
			}
		}
		
		protected var _active:Boolean = true;
		protected var _over:Boolean;
		protected var _down:Boolean;
		protected var _lastLabel:String;
		
		protected var _clickAct:Act;
		protected var _mouseDownAct:Act;
		protected var _mouseUpAct:Act;
		protected var _rollOverAct:Act;
		protected var _rollOutAct:Act;
		
		public function Button(asset:DisplayObject=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			_lastLabel = null;
			asset.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			asset.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			asset.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			asset.addEventListener(MouseEvent.CLICK,onClick);
			if(_spriteAsset){
				_spriteAsset.buttonMode = _active;
			}
			assessLabel();
		}
		override protected function unbindFromAsset() : void{
			asset.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			asset.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
			asset.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			asset.removeEventListener(MouseEvent.CLICK,onClick);
		}
		override protected function draw() : void{
			var bounds:Rectangle = getAssetBounds();
			asset.x = displayPosition.x-bounds.x;
			asset.y = displayPosition.y-bounds.y;
		}
		private function onRollOver(e:Event):void{
			if(_active){
				_over = true;
				assessLabel();
				if(_rollOverAct){
					_rollOverAct.perform(this);
				}
			}
		}
		private function onRollOut(e:Event):void{
			if(_active){
				_over = false;
				assessLabel();
				if(_rollOutAct){
					_rollOutAct.perform(this);
				}
			}
		}
		private function onMouseDown(e:Event):void{
			if(_active){
				asset.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_down = true;
				assessLabel();
				if(_mouseDownAct)_mouseDownAct.perform(this);
			}
		}
		private function onMouseUp(e:Event):void{
			if(_active){
				asset.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_down = false;
				assessLabel();
				if(_mouseUpAct)_mouseUpAct.perform(this);
			}
		}
		private function onClick(e:Event):void{
			if(_clickAct && _active){
				var assetMatch:Boolean = (e.target==asset);
				if(!assetMatch){
					var cast:Sprite = (e.target as Sprite);
					if(!cast || !cast.buttonMode){
						assetMatch = true;
					}
				}
				if(assetMatch){
					_clickAct.perform(this);
				}
			}
		}
		protected function assessLabel():void{
			if(_movieClipAsset){
				var labels:Array = [];
				if(!_active){
					labels.push(INACTIVE_FRAME_LABEL);
				}
				if(_down){
					labels.push(DOWN_FRAME_LABEL);
				}else if(_lastLabel==DOWN_FRAME_LABEL){
					labels.push(UP_FRAME_LABEL);
				}
				if(_over){
					labels.push(OVER_FRAME_LABEL);
				}else{
					labels.push(OUT_FRAME_LABEL);
				}
				setLabel(labels);
			}
		}
		protected function setLabel(labels:Array):void{
			for each(var label:String in labels){
				if(MovieClipUtils.getFrameLabelDuration(_movieClipAsset,label)!=-1){
					if(_lastLabel!=label){
						_lastLabel = label;
						playAssetFrameLabel(label);
					}
					break;
				}
			}
		}
	}
}