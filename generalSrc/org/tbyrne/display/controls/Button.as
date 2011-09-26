package org.tbyrne.display.controls
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.ISprite;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.display.assets.states.StateDef;
	
	use namespace DisplayNamespace;
	
	public class Button extends Control
	{
		private static var DUMMY_POINT:Point = new Point();
		
		DisplayNamespace static const STATE_OVER:String = "mouseOver";
		DisplayNamespace static const STATE_OUT:String = "mouseOut";
		DisplayNamespace static const STATE_DOWN:String = "mouseDown";
		DisplayNamespace static const STATE_UP:String = "mouseUp";
		
		
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
		
		override public function set asset(value:IDisplayObject) : void{
			super.asset = value;
			invalidateMeasurements();
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
				invalidateSize();
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
		
		/**
		 * This is a number representing the amount of pixels the mouse can move between
		 * pressing and releasing before it is no longer considered a click (the release
		 * act will still fire).
		 * 
		 * @default 10
		 */
		public var dragAvoidanceDist:Number = 10;
		
		protected var _data:*;
		protected var _triggerableData:ITriggerableAction;
		
		protected var _useHandCursor:Boolean = true;
		protected var _scaleAsset:Boolean = false;
		protected var _over:Boolean;
		protected var _down:Boolean;
		protected var _acceptClick:Boolean;
		protected var _focused:Boolean;
		
		protected var _pressedStage:IStage;
		
		protected var _overState:StateDef = new StateDef([STATE_OVER,STATE_OUT],1);
		protected var _downState:StateDef = new StateDef([STATE_DOWN,STATE_UP],1);
		
		protected var _interactiveArea:ISprite;
		
		protected var _clicked:Act;
		protected var _mousePressed:Act;
		protected var _mouseReleased:Act;
		protected var _rolledOver:Act;
		protected var _rolledOut:Act;
		
		protected var _pressedPos:Point;
		
		public function Button(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			
			_interactiveArea = _asset.factory.createHitArea();
			_containerAsset.addAsset(_interactiveArea);
			_asset.added.addHandler(onChildAdded);
			
			_interactiveArea.mousePressed.addHandler(onMouseDown);
			_interactiveArea.rolledOver.addHandler(onRollOver);
			_interactiveArea.rolledOut.addHandler(onRollOut);
			_interactiveArea.focusIn.addHandler(onFocusIn);
			_interactiveArea.focusOut.addHandler(onFocusOut);
			_interactiveArea.clicked.addHandler(onClick);
			_interactiveArea.keyUp.addHandler(onKeyUp);
			_interactiveArea.focusRect = false;
			
			//_containerAsset.mouseChildren = false;
			
			_interactiveArea.buttonMode = _active;
			_interactiveArea.useHandCursor = (_active && _useHandCursor);
		}
		override protected function unbindFromAsset() : void{
			_asset.added.removeHandler(onChildAdded);
			_containerAsset.removeAsset(_interactiveArea);
			
			_interactiveArea.mousePressed.removeHandler(onMouseDown);
			_interactiveArea.rolledOver.removeHandler(onRollOver);
			_interactiveArea.rolledOut.removeHandler(onRollOut);
			_interactiveArea.focusIn.removeHandler(onFocusIn);
			_interactiveArea.focusOut.removeHandler(onFocusOut);
			_interactiveArea.clicked.removeHandler(onClick);
			_interactiveArea.keyUp.removeHandler(onKeyUp);
			_interactiveArea.focusRect = null;
			
			_asset.factory.destroyAsset(_interactiveArea);
			_interactiveArea = null;
			
			//_containerAsset.mouseChildren = true;
			super.unbindFromAsset();
		}
		override protected function onRemovedFromStage(from:IAsset=null):void{
			if(down)killMouseDown();
			if(_over)onRollOut(_interactiveArea);
			super.onRemovedFromStage(from);
		}
		protected function onChildAdded(e:Event, from:IDisplayObject) : void{
			//TODO: when events are replaced with Info objects, do a check here to see if it's a descendant or not
			_containerAsset.setAssetIndex(_interactiveArea,_containerAsset.numChildren-1);
		}
		override protected function commitSize() : void{
			if(_scaleAsset){
				_interactiveArea.setSize(0.01,0.01);
				asset.setSize(size.x,size.y);
				_interactiveArea.setSize(size.x/asset.scaleX,size.y/asset.scaleY);
			}else{
				var meas:Point = measurements;
				_interactiveArea.setSize(meas.x/asset.scaleX,meas.y/asset.scaleY);
			}
		}
		protected function onRollOver(from:IInteractiveObject, info:IMouseActInfo):void{
			if(_active){
				_over = true;
				_overState.selection = (_over || _focused?0:1);
				if(_rolledOver){
					_rolledOver.perform(this);
				}
			}
		}
		protected function onRollOut(from:IInteractiveObject, info:IMouseActInfo=null):void{
			if(_active){
				_over = false;
				_overState.selection = (_over || _focused?0:1);
				if(_rolledOut){
					_rolledOut.perform(this);
				}
			}
		}
		protected function onFocusIn(from:IInteractiveObject):void{
			if(_active){
				_focused = true;
				_overState.selection = (_over || _focused?0:1);
			}
		}
		protected function onFocusOut(from:IInteractiveObject):void{
			if(_active){
				_focused = false;
				_overState.selection = (_over || _focused?0:1);
			}
		}
		protected function onMouseDown(from:IInteractiveObject, info:IMouseActInfo):void{
			if(_active){
				_pressedStage = asset.stage;
				_pressedStage.mouseMoved.addHandler(onMouseMove);
				_pressedStage.mouseReleased.addHandler(onMouseUp);
				
				_downState.selection = 0;
				_down = true;
				_acceptClick = true;
				if(_mousePressed)_mousePressed.perform(this);
				
				if(!_pressedPos)_pressedPos = new Point();
				_pressedPos.x = _asset.mouseX;
				_pressedPos.y = _asset.mouseY;
			}
		}
		protected function onMouseMove(from:IInteractiveObject, info:IMouseActInfo=null):void{
			DUMMY_POINT.x = _asset.mouseX;
			DUMMY_POINT.y = _asset.mouseY;
			if(Point.distance(_pressedPos,DUMMY_POINT)>dragAvoidanceDist){
				_acceptClick = false;
				killMouseDown();
			}
		}
		protected function onMouseUp(from:IInteractiveObject, info:IMouseActInfo=null):void{
			killMouseDown();
		}
		
		protected function killMouseDown():void{
			_pressedStage.mouseMoved.removeHandler(onMouseMove);
			_pressedStage.mouseReleased.removeHandler(onMouseUp);
			if(_active){
				_pressedStage = null;
				_downState.selection = 1;
				_down = false;
				if(_mouseReleased)_mouseReleased.perform(this);
			}
		}
		
		protected final function onClick(from:IInteractiveObject, info:IMouseActInfo):void{
			if(_active && _acceptClick && info.mouseTarget==_interactiveArea){
				acceptClick();
			}
			_acceptClick = false;
		}
		
		protected final function onKeyUp(from:IInteractiveObject, info:IKeyActInfo):void{
			if(_active && info.keyCode==Keyboard.ENTER){
				acceptClick();
			}
		}
		
		
		protected function acceptClick():void{
			if(_clicked)_clicked.perform(this);
			if(_triggerableData)_triggerableData.triggerAction(asset);
		}
		
		
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_overState);
			fill.push(_downState);
			return fill;
		}
	}
}