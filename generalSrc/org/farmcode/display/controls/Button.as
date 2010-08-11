package org.farmcode.display.controls
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.ISpriteAsset;
	import org.farmcode.display.assets.states.StateDef;
	
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
		
		/**
		 * handler(button:Button)
		 */
		public function get clicked():IAct{
			if(!_clicked)_clicked = new Act();
			return _clicked;
		}
		/**
		 * handler(button:Button)
		 */
		public function get mousePressed():IAct{
			if(!_mousePressed)_mousePressed = new Act();
			return _mousePressed;
		}
		/**
		 * handler(button:Button)
		 */
		public function get mouseReleased():IAct{
			if(!_mouseReleased)_mouseReleased = new Act();
			return _mouseReleased;
		}
		/**
		 * handler(button:Button)
		 */
		public function get rolledOver():IAct{
			if(!_rolledOver)_rolledOver = new Act();
			return _rolledOver;
		}
		/**
		 * handler(button:Button)
		 */
		public function get rolledOut():IAct{
			if(!_rolledOut)_rolledOut = new Act();
			return _rolledOut;
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
				if(_interactiveArea){
					_interactiveArea.buttonMode = value;
					_interactiveArea.useHandCursor = (value && _useHandCursor);
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
		
		protected var _interactiveArea:ISpriteAsset;
		
		protected var _clicked:Act;
		protected var _mousePressed:Act;
		protected var _mouseReleased:Act;
		protected var _rolledOver:Act;
		protected var _rolledOut:Act;
		
		public function Button(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_asset.added.addHandler(onChildAdded);
			
			_interactiveArea = _asset.createAsset(ISpriteAsset);
			_interactiveArea.graphics.beginFill(0,0);
			_interactiveArea.graphics.drawRect(0,0,10,10);
			_interactiveArea.graphics.endFill();
			_containerAsset.addAsset(_interactiveArea);
			
			_interactiveArea.mouseReleased.addHandler(onMouseDown);
			_interactiveArea.rolledOver.addHandler(onRollOver);
			_interactiveArea.rolledOut.addHandler(onRollOut);
			_interactiveArea.clicked.addHandler(onClick);
			
			//_containerAsset.mouseChildren = false;
			
			_interactiveArea.buttonMode = _active;
			_interactiveArea.useHandCursor = (_active && _useHandCursor);
		}
		override protected function unbindFromAsset() : void{
			if(down)onMouseUp(_interactiveArea);
			_containerAsset.removeAsset(_interactiveArea);
			
			_interactiveArea.mouseReleased.removeHandler(onMouseDown);
			_interactiveArea.rolledOver.removeHandler(onRollOver);
			_interactiveArea.rolledOut.removeHandler(onRollOut);
			_interactiveArea.clicked.removeHandler(onClick);
			
			_asset.destroyAsset(_interactiveArea);
			_interactiveArea = null;
			
			//_containerAsset.mouseChildren = true;
			_asset.added.removeHandler(onChildAdded);
			super.unbindFromAsset();
		}
		protected function onChildAdded(e:Event, from:IDisplayAsset) : void{
			//TODO: when events are replaced with Info objects, do a check here to see if it's a descendant or not
			_containerAsset.setAssetIndex(_interactiveArea,_containerAsset.numChildren-1);
		}
		override protected function measure() : void{
			super.measure();
		}
		override protected function draw() : void{
			positionAsset();
			if(_scaleAsset){
				asset.width = displayPosition.width;
				asset.height = displayPosition.height;
			}
			var meas:Point = measurements;
			_interactiveArea.width = meas.x;
			_interactiveArea.height = meas.y;
		}
		private function onRollOver(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				_overState.selection = 0;
				_over = true;
				if(_rolledOver){
					_rolledOver.perform(this);
				}
			}
		}
		private function onRollOut(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				_overState.selection = 1;
				_over = false;
				if(_rolledOut){
					_rolledOut.perform(this);
				}
			}
		}
		private function onMouseDown(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				asset.stage.mousePressed.addHandler(onMouseUp);
				_downState.selection = 0;
				_down = true;
				if(_mousePressed)_mousePressed.perform(this);
			}
		}
		private function onMouseUp(from:IInteractiveObjectAsset, info:IMouseActInfo=null):void{
			if(_active){
				asset.stage.mousePressed.removeHandler(onMouseUp);
				_downState.selection = 1;
				_down = false;
				if(_mouseReleased)_mouseReleased.perform(this);
			}
		}
		private function onClick(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			if(_active){
				var assetMatch:Boolean = (info.mouseTarget==_interactiveArea);
				/*if(!assetMatch){
					var cast:ISpriteAsset = (info.mouseTarget as ISpriteAsset);
					if(!cast || !cast.buttonMode){
						assetMatch = true;
					}
				}*/
				if(assetMatch){
					if(_clicked)_clicked.perform(this);
					if(_triggerableData)_triggerableData.triggerAction(asset);
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