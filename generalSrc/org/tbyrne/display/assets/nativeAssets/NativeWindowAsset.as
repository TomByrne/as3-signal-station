package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.acts.NativeAct;
	import org.tbyrne.display.assets.IAssetFactory;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.INativeWindow;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	
	public class NativeWindowAsset extends NativeAsset implements INativeWindow
	{
		
		/**
		 * handler(from:NativeWindowAsset)
		 */
		public function get activated():IAct{
			return ((_activated) || (_activated = new NativeAct(_nativeWindow,Event.ACTIVATE,[this],false)));
		}
		
		/**
		 * handler(from:NativeWindowAsset)
		 */
		public function get closed():IAct{
			return ((_closed) || (_closed = new NativeAct(_nativeWindow,Event.CLOSE,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get closing():IAct{
			return ((_closing) || (_closing = new NativeAct(_nativeWindow,Event.CLOSING,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get deactivate():IAct{
			return ((_deactivate) || (_deactivate = new NativeAct(_nativeWindow,Event.DEACTIVATE,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get displayStateChange():IAct{
			return ((_displayStateChange) || (_displayStateChange = new NativeAct(_nativeWindow,NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get displayStateChanging():IAct{
			return ((_displayStateChanging) || (_displayStateChanging = new NativeAct(_nativeWindow,NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get moved():IAct{
			return ((_move) || (_move = new NativeAct(_nativeWindow,NativeWindowBoundsEvent.MOVE,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get moving():IAct{
			return ((_moving) || (_moving = new NativeAct(_nativeWindow,NativeWindowBoundsEvent.MOVING,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get resized():IAct{
			return ((_resize) || (_resize = new NativeAct(_nativeWindow,NativeWindowBoundsEvent.RESIZE,[this],false)));
		}
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get resizing():IAct{
			return ((_resizing) || (_resizing = new NativeAct(_nativeWindow,NativeWindowBoundsEvent.RESIZING,[this],false)));
		}
		
		protected var _resizing:NativeAct;
		protected var _resize:NativeAct;
		protected var _moving:NativeAct;
		protected var _move:NativeAct;
		protected var _displayStateChanging:NativeAct;
		protected var _displayStateChange:NativeAct;
		protected var _deactivate:NativeAct;
		protected var _closing:NativeAct;
		protected var _closed:NativeAct;
		protected var _activated:NativeAct;
		
		override internal function get display():*{
			return displayObject;
		}
		override internal function set display(value:*):void{
			displayObject = value as NativeWindow;
		}
			
		public function get displayObject():NativeWindow{
			return _nativeWindow;
		}
		public function set displayObject(value:NativeWindow):void {
			if(super.display!=value) {
				super.display = value;
				if(value){
					_nativeWindow = value as NativeWindow;
				}else{
					_nativeWindow = null;
				}
			}
		}
		
		protected var _nativeWindow:NativeWindow;
		
		
		
		public function NativeWindowAsset(factory:IAssetFactory){
			super(factory);
		}
		
		public function get active():Boolean
		{
			return _nativeWindow.active;
		}
		
		public function get alwaysInFront():Boolean
		{
			return _nativeWindow.active;
		}
		
		public function set alwaysInFront(value:Boolean):void
		{
			_nativeWindow.alwaysInFront = value;
		}
		
		public function get bounds():Rectangle
		{
			return _nativeWindow.bounds;
		}
		
		public function set bounds(value:Rectangle):void
		{
			_nativeWindow.bounds = value;
		}
		
		public function get isClosed():Boolean
		{
			return _nativeWindow.closed;
		}
		
		public function get displayState():String
		{
			return _nativeWindow.displayState;
		}
		
		public function get maximizable():Boolean
		{
			return _nativeWindow.maximizable;
		}
		
		public function get maxSize():Point
		{
			return _nativeWindow.maxSize;
		}
		
		public function set maxSize(value:Point):void
		{
			_nativeWindow.maxSize = value;
		}
		
		public function get menu():NativeMenu
		{
			return _nativeWindow.menu;
		}
		
		public function set menu(value:NativeMenu):void
		{
			_nativeWindow.menu = value;
		}
		
		public function get minimizable():Boolean
		{
			return _nativeWindow.minimizable;
		}
		
		public function get minSize():Point
		{
			return _nativeWindow.minSize;
		}
		
		public function set minSize(value:Point):void
		{
			_nativeWindow.minSize = value;
		}
		
		public function get resizable():Boolean
		{
			return _nativeWindow.resizable;
		}
		
		public function get systemChrome():String
		{
			return _nativeWindow.systemChrome;
		}
		
		public function get title():String
		{
			return _nativeWindow.title;
		}
		
		public function set title(value:String):void
		{
			_nativeWindow.title = value;
		}
		
		public function get transparent():Boolean
		{
			return _nativeWindow.transparent;
		}
		
		public function get type():String
		{
			return _nativeWindow.type;
		}
		
		public function activate():void
		{
			_nativeWindow.activate();
		}
		
		public function close():void
		{
			_nativeWindow.close();
		}
		
		public function globalToScreen(globalPoint:Point):Point
		{
			return _nativeWindow.globalToScreen(globalPoint);
		}
		
		public function maximize():void
		{
			_nativeWindow.maximize();
		}
		
		public function minimize():void
		{
			_nativeWindow.minimize();
		}
		
		public function notifyUser(type:String):void
		{
			_nativeWindow.notifyUser(type);
		}
		
		public function orderInBackOf(nativeWindow:INativeWindow):Boolean
		{
			var cast:NativeWindowAsset = (nativeWindow as NativeWindowAsset);
			return _nativeWindow.orderInBackOf(cast.displayObject);
		}
		
		public function orderInFrontOf(nativeWindow:INativeWindow):Boolean
		{
			var cast:NativeWindowAsset = (nativeWindow as NativeWindowAsset);
			return _nativeWindow.orderInFrontOf(cast.displayObject);
		}
		
		public function restore():void
		{
			_nativeWindow.restore();
		}
		
		public function startMove():Boolean
		{
			return _nativeWindow.startMove();;
		}
		
		public function startResize(edgeOrCorner:String):Boolean
		{
			return _nativeWindow.startResize(edgeOrCorner);
		}
	}
}