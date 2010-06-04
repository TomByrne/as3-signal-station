package org.farmcode.display.controls
{
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.ISpriteAsset;
	import org.farmcode.display.assets.states.IStateDef;
	import org.farmcode.display.assets.states.StateDef;
	import org.farmcode.display.utils.MovieClipUtils;
	import org.farmcode.sodality.advice.IAdvice;
	
	use namespace DisplayNamespace;
	
	public class Button extends Control
	{
		internal static var OVER_FRAME_LABEL:String = "mouseOver";
		internal static var OUT_FRAME_LABEL:String = "mouseOut";
		internal static var DOWN_FRAME_LABEL:String = "mouseDown";
		internal static var UP_FRAME_LABEL:String = "mouseUp";
		
		
		public function get data():*{
			return _data;
		}
		public function set data(value:*):void{
			if(_data != value){
				_data = value;
				if(value){
					_triggerableData = (value as ITriggerableAction);
				}else{
					_triggerableData = null;
				}
			}
		}
		
		
		public function get useHandCursor():Boolean{
			return _useHandCursor;
		}
		public function set useHandCursor(value:Boolean):void{
			if(_useHandCursor!=value){
				_useHandCursor = value;
				if(_spriteAsset && _active){
					_spriteAsset.useHandCursor = _useHandCursor;
				}
			}
		}
		
		override public function set asset(value:IDisplayAsset) : void{
			super.asset = value;
			dispatchMeasurementChange();
		}
		
		//TODO: rename acts into past-tense without 'Act' (e.g. mouseDownAct > mousedDown, rollOverAct > rolledOver)
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
		
		
		DisplayNamespace function get scaleAsset():Boolean{
			return _scaleAsset;
		}
		DisplayNamespace function set scaleAsset(value:Boolean):void{
			if(_scaleAsset!=value){
				_scaleAsset = value;
				invalidate();
			}
		}
		
		override public function set active(value:Boolean):void{
			if(super.active!=value){
				if(!value){
					_overState.selection = 1;
					_downState.selection = 1;
					
					_over = false;
					_down = false;
				}
				if(_spriteAsset){
					_spriteAsset.buttonMode = value;
					_spriteAsset.useHandCursor = (value && _useHandCursor);
				}
				super.active = value;
			}
		}
		
		protected var _data:*;
		protected var _triggerableData:ITriggerableAction;
		
		protected var _useHandCursor:Boolean = true;
		protected var _scaleAsset:Boolean = false;
		protected var _over:Boolean;
		protected var _down:Boolean;
		
		protected var _overState:StateDef = new StateDef([OVER_FRAME_LABEL,OUT_FRAME_LABEL],1);
		protected var _downState:StateDef = new StateDef([DOWN_FRAME_LABEL,UP_FRAME_LABEL],1);
		
		protected var _clickAct:Act;
		protected var _mouseDownAct:Act;
		protected var _mouseUpAct:Act;
		protected var _rollOverAct:Act;
		protected var _rollOutAct:Act;
		
		public function Button(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_interactiveObjectAsset.mouseDown.addHandler(onMouseDown);
			_interactiveObjectAsset.rollOver.addHandler(onRollOver);
			_interactiveObjectAsset.rollOut.addHandler(onRollOut);
			_interactiveObjectAsset.click.addHandler(onClick);
			
			_containerAsset.mouseChildren = false;
			
			if(_spriteAsset){
				_spriteAsset.buttonMode = _active;
				_spriteAsset.useHandCursor = (_active && _useHandCursor);
			}
		}
		override protected function unbindFromAsset() : void{
			_interactiveObjectAsset.mouseDown.removeHandler(onMouseDown);
			_interactiveObjectAsset.rollOver.removeHandler(onRollOver);
			_interactiveObjectAsset.rollOut.removeHandler(onRollOut);
			_interactiveObjectAsset.click.removeHandler(onClick);
			
			_containerAsset.mouseChildren = true;
			super.unbindFromAsset();
		}
		override protected function draw() : void{
			positionAsset();
			if(_scaleAsset){
				asset.width = displayPosition.width;
				asset.height = displayPosition.height;
			}
		}
		private function onRollOver(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				_overState.selection = 0;
				_over = true;
				if(_rollOverAct){
					_rollOverAct.perform(this);
				}
			}
		}
		private function onRollOut(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				_overState.selection = 1;
				_over = false;
				if(_rollOutAct){
					_rollOutAct.perform(this);
				}
			}
		}
		private function onMouseDown(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				asset.stage.mouseUp.addHandler(onMouseUp);
				_downState.selection = 0;
				_down = true;
				if(_mouseDownAct)_mouseDownAct.perform(this);
			}
		}
		private function onMouseUp(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				asset.stage.mouseUp.removeHandler(onMouseUp);
				_downState.selection = 1;
				_down = false;
				if(_mouseUpAct)_mouseUpAct.perform(this);
			}
		}
		private function onClick(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				var assetMatch:Boolean = (info.mouseTarget==asset);
				if(!assetMatch){
					var cast:ISpriteAsset = (info.mouseTarget as ISpriteAsset);
					if(!cast || !cast.buttonMode){
						assetMatch = true;
					}
				}
				if(assetMatch){
					if(_clickAct)_clickAct.perform(this);
					if(_triggerableData)_triggerableData.triggerAction(asset.drawDisplay as DisplayObject);
				}
			}
		}
		
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_overState);
			fill.push(_downState);
			return fill;
		}
	}
}