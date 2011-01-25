package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.acts.NativeAct;
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeAssets.actInfo.KeyActInfo;
	import org.tbyrne.display.assets.nativeAssets.actInfo.MouseActInfo;

	public class InteractiveObjectAsset extends DisplayObjectAsset implements IInteractiveObject
	{
		
		/**
		 * @inheritDoc
		 */
		public function get mouseReleased():IAct{
			if(!_mouseUp)_mouseUp = new Act();
			confirmListening(MouseEvent.MOUSE_UP);
			return _mouseUp;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mousePressed():IAct{
			if(!_mouseDown)_mouseDown = new Act();
			confirmListening(MouseEvent.MOUSE_DOWN);
			return _mouseDown;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mousedOver():IAct{
			if(!_mouseOver)_mouseOver = new Act();
			confirmListening(MouseEvent.MOUSE_OVER);
			return _mouseOver;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mousedOut():IAct{
			if(!_mouseOut)_mouseOut = new Act();
			confirmListening(MouseEvent.MOUSE_OUT);
			return _mouseOut;
		}
		/**
		 * @inheritDoc
		 */
		public function get rolledOver():IAct{
			if(!_rollOver)_rollOver = new Act();
			confirmListening(MouseEvent.ROLL_OVER);
			return _rollOver;
		}
		/**
		 * @inheritDoc
		 */
		public function get rolledOut():IAct{
			if(!_rollOut)_rollOut = new Act();
			confirmListening(MouseEvent.ROLL_OUT);
			return _rollOut;
		}
		/**
		 * @inheritDoc
		 */
		public function get mouseMoved():IAct{
			if(!_mouseMove)_mouseMove = new Act();
			confirmListening(MouseEvent.MOUSE_MOVE);
			return _mouseMove;
		}
		/**
		 * @inheritDoc
		 */
		public function get clicked():IAct{
			if(!_click)_click = new Act();
			confirmListening(MouseEvent.CLICK);
			return _click;
		}
		/**
		 * @inheritDoc
		 */
		public function get doubleClicked():IAct{
			if(!_doubleClick)_doubleClick = new Act();
			confirmListening(MouseEvent.DOUBLE_CLICK);
			return _doubleClick;
		}
		/**
		 * @inheritDoc
		 */
		public function get mouseWheel():IAct{
			if(!_mouseWheel)_mouseWheel = new Act();
			confirmListening(MouseEvent.MOUSE_WHEEL);
			return _mouseWheel;
		}
		/**
		 * @inheritDoc
		 */
		public function get focusIn():IAct{
			if(!_focusIn)_focusIn = new NativeAct(_interactiveObject,FocusEvent.FOCUS_IN,[this]);
			return _focusIn;
		}
		/**
		 * @inheritDoc
		 */
		public function get focusOut():IAct{
			if(!_focusOut)_focusOut = new NativeAct(_interactiveObject,FocusEvent.FOCUS_OUT,[this]);
			return _focusOut;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get keyUp():IAct{
			if(!_keyUp)_keyUp = new Act();
			confirmListening(KeyboardEvent.KEY_UP);
			return _keyUp;
		}
		/**
		 * @inheritDoc
		 */
		public function get keyDown():IAct{
			if(!_keyDown)_keyDown = new Act();
			confirmListening(KeyboardEvent.KEY_DOWN);
			return _keyDown;
		}
		
		
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				var bundle:EventBundle;
				if(_interactiveObject){
					for each(bundle in eventBundles){
						if(bundle.listening){
							bundle.listening = false;
							_interactiveObject.removeEventListener(bundle.eventName, bundle.handler);
						}
					}
				}
				super.displayObject = value;
				if(value){
					_interactiveObject = value as InteractiveObject;
					for each(bundle in eventBundles){
						if(this[bundle.actName]){
							bundle.listening = true;
							_interactiveObject.addEventListener(bundle.eventName, bundle.handler);
						}
					}
				}else{
					_interactiveObject = null;
				}
				
				if(_focusIn)_focusIn.eventDispatcher = value;
				if(_focusOut)_focusOut.eventDispatcher = value;
			}
		}
		
		public function get tabEnabled():Boolean{
			return _interactiveObject.tabEnabled;
		}
		public function set tabEnabled(value:Boolean):void{
			_interactiveObject.tabEnabled = value;
		}
		
		public function get doubleClickEnabled():Boolean{
			return _interactiveObject.doubleClickEnabled;
		}
		public function set doubleClickEnabled(value:Boolean):void{
			_interactiveObject.doubleClickEnabled = value;
		}
		
		public function get mouseEnabled():Boolean{
			return _interactiveObject.mouseEnabled;
		}
		public function set mouseEnabled(value:Boolean):void{
			_interactiveObject.mouseEnabled = value;
		}
		
		public function get tabIndex():int{
			return _interactiveObject.tabIndex;
		}
		public function set tabIndex(value:int):void{
			_interactiveObject.tabIndex = value;
		}
		
		protected var _focusIn:NativeAct;
		protected var _focusOut:NativeAct;
		
		protected var _keyDown:Act;
		protected var _keyUp:Act;
		protected var _mouseWheel:Act;
		protected var _click:Act;
		protected var _doubleClick:Act;
		protected var _mouseMove:Act;
		protected var _rollOut:Act;
		protected var _rollOver:Act;
		protected var _mouseOut:Act;
		protected var _mouseOver:Act;
		protected var _mouseUp:Act;
		protected var _mouseDown:Act;
		
		private var _interactiveObject:InteractiveObject;
		
		private var eventBundles:Array;
		
		public function InteractiveObjectAsset(factory:NativeAssetFactory=null){
			super(factory);
			eventBundles = [new EventBundle(MouseEvent.MOUSE_WHEEL, "_mouseWheel", onMouseWheel),
							new EventBundle(MouseEvent.CLICK, "_click", onMouseEvent),
							new EventBundle(MouseEvent.DOUBLE_CLICK, "_doubleClick", onMouseEvent),
							new EventBundle(MouseEvent.MOUSE_MOVE, "_mouseMove", onMouseEvent),
							new EventBundle(MouseEvent.ROLL_OUT, "_rollOut", onMouseEvent),
							new EventBundle(MouseEvent.ROLL_OVER, "_rollOver", onMouseEvent),
							new EventBundle(MouseEvent.MOUSE_OUT, "_mouseOut", onMouseEvent),
							new EventBundle(MouseEvent.MOUSE_OVER, "_mouseOver", onMouseEvent),
							new EventBundle(MouseEvent.MOUSE_UP, "_mouseUp", onMouseEvent),
							new EventBundle(MouseEvent.MOUSE_DOWN, "_mouseDown", onMouseEvent),
							new EventBundle(KeyboardEvent.KEY_UP, "_keyUp", onKeyEvent),
							new EventBundle(KeyboardEvent.KEY_DOWN, "_keyDown", onKeyEvent)];
		}
		protected function onMouseEvent(e:MouseEvent):void{
			var act:Act = this["_"+e.type];
			if(act){
				act.perform(this,createMouseInfo(e));
			}
		}
		protected function onKeyEvent(e:KeyboardEvent):void{
			var act:Act = this["_"+e.type];
			if(act){
				act.perform(this,createKeyInfo(e));
			}
		}
		protected function onMouseWheel(e:MouseEvent):void{
			if(_mouseWheel)_mouseWheel.perform(this,createMouseInfo(e),e.delta);
		}
		protected function createMouseInfo(e:MouseEvent):IMouseActInfo{
			var target:IDisplayObject = (e.target==_interactiveObject?this:_nativeFactory.getNew(e.target as DisplayObject));
			return new MouseActInfo(target, e.altKey, e.ctrlKey, e.shiftKey);
		}
		protected function createKeyInfo(e:KeyboardEvent):IKeyActInfo{
			var target:IDisplayObject = (e.target==_interactiveObject?this:_nativeFactory.getNew(e.target as DisplayObject));
			return new KeyActInfo(target, e.altKey, e.ctrlKey, e.shiftKey, e.charCode, e.keyCode, e.keyLocation);
		}
		
		protected function confirmListening(eventName:String):void{
			var bundle:EventBundle = findBundle(eventName);
			if(!bundle.listening && _interactiveObject){
				bundle.listening = true;
				_interactiveObject.addEventListener(bundle.eventName, bundle.handler);
			}
		}
		protected function findBundle(eventName:String):EventBundle{
			for each(var bundle:EventBundle in eventBundles){
				if(bundle.eventName==eventName){
					return bundle
				}
			}
			return null;
		}
	}
}
class EventBundle{
	public var eventName:String;
	public var actName:String;
	public var listening:Boolean;
	public var handler:Function;
	
	public function EventBundle(eventName:String, actName:String, handler:Function){
		this.eventName = eventName;
		this.actName = actName;
		this.handler = handler;
	}
}