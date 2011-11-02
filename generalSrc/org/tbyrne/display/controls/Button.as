package org.tbyrne.display.controls
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import org.tbyrne.actInfo.IKeyActInfo;
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.DisplayNamespace;
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
		
		
		
		public function get useHandCursor():Boolean{
			return _useHandCursor;
		}
		public function set useHandCursor(value:Boolean):void{
			if(_useHandCursor!=value){
				_useHandCursor = value;
				if(_interactiveSprite && _active){
					_interactiveSprite.useHandCursor = _useHandCursor && _active;
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
		
		
		/**
		 * This is a number representing the amount of pixels the mouse can move between
		 * pressing and releasing before it is no longer considered a click (the release
		 * act will still fire).
		 * 
		 * @default 10
		 */
		public var dragAvoidanceDist:Number = 10;
		
		protected var _useHandCursor:Boolean = true;
		protected var _scaleAsset:Boolean = false;
		protected var _over:Boolean;
		protected var _down:Boolean;
		protected var _acceptClick:Boolean;
		protected var _focused:Boolean;
		
		protected var _pressedStage:IStage;
		
		protected var _overState:StateDef = new StateDef([STATE_OVER,STATE_OUT],1);
		protected var _downState:StateDef = new StateDef([STATE_DOWN,STATE_UP],1);
		
		protected var _interactiveSprite:ISprite;
		protected var _interactiveAsset:IInteractiveObject;
		
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
			
			_asset.added.addHandler(onChildAdded);
			setInteractiveArea(_interactiveObjectAsset);
		}
		override protected function unbindFromAsset() : void{
			_asset.added.removeHandler(onChildAdded);
			
			if(_interactiveAsset==_interactiveObjectAsset)setInteractiveArea(null);
			super.unbindFromAsset();
		}
		protected function setInteractiveArea(interactiveAsset:IInteractiveObject):void{
			if(_interactiveAsset!=interactiveAsset){
				if(_interactiveAsset){
					_interactiveAsset.mousePressed.removeHandler(onMouseDown);
					_interactiveAsset.rolledOver.removeHandler(onRollOver);
					_interactiveAsset.rolledOut.removeHandler(onRollOut);
					_interactiveAsset.focusIn.removeHandler(onFocusIn);
					_interactiveAsset.focusOut.removeHandler(onFocusOut);
					_interactiveAsset.clicked.removeHandler(onClick);
					_interactiveAsset.keyUp.removeHandler(onKeyUp);
					_interactiveAsset.focusRect = null;
					_interactiveSprite = null;
				}
				_interactiveAsset = interactiveAsset;
				if(_interactiveAsset){
					_interactiveAsset.mousePressed.addHandler(onMouseDown);
					_interactiveAsset.rolledOver.addHandler(onRollOver);
					_interactiveAsset.rolledOut.addHandler(onRollOut);
					_interactiveAsset.focusIn.addHandler(onFocusIn);
					_interactiveAsset.focusOut.addHandler(onFocusOut);
					_interactiveAsset.clicked.addHandler(onClick);
					_interactiveAsset.keyUp.addHandler(onKeyUp);
					_interactiveAsset.focusRect = false;
					
					_interactiveSprite = (_interactiveAsset as ISprite);
					if(_interactiveSprite){
						_interactiveSprite.mouseChildren = false;
						_interactiveSprite.buttonMode = _active;
						_interactiveSprite.useHandCursor = (_active && _useHandCursor);
					}
				}
			}
		}
		override protected function onRemovedFromStage(from:IAsset=null):void{
			if(down)killMouseDown();
			if(_over)onRollOut(_interactiveAsset);
			super.onRemovedFromStage(from);
		}
		protected function onChildAdded(e:Event, from:IDisplayObject) : void{
			//TODO: when events are replaced with Info objects, do a check here to see if it's a descendant or not
			if(_interactiveAsset!=_asset)_containerAsset.setAssetIndex(_interactiveAsset,_containerAsset.numChildren-1);
		}
		override protected function commitSize() : void{
			if(_scaleAsset){
				asset.setSize(size.x,size.y);
				if(_interactiveAsset!=_asset){
					_interactiveAsset.setSize(size.x,size.y);
				}
			}else{
				var meas:Point = measurements;
				asset.setSize(meas.x,meas.y);
				if(_interactiveAsset!=_asset){
					_interactiveAsset.setSize(meas.x,meas.y);
				}
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
			if(_active && _acceptClick && info.mouseTarget==_interactiveAsset){
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
			if(_data && _data.selectedAction)_data.selectedAction.triggerAction(asset);
		}
		
		
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_overState);
			fill.push(_downState);
			return fill;
		}
		
		
		override protected function setActive(value:Boolean):void{
			if(_active!=value){
				if(!value){
					_overState.selection = 1;
					_downState.selection = 1;
					
					_over = false;
					_down = false;
				}
				if(_interactiveSprite){
					_interactiveSprite.buttonMode = value;
					_interactiveSprite.useHandCursor = (value && _useHandCursor);
				}
				super.setActive(value);
			}
		}
	}
}