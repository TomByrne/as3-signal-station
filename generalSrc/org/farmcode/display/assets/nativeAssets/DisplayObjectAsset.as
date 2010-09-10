package org.farmcode.display.assets.nativeAssets {
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.acts.NativeAct;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IStageAsset;
	import org.farmcode.instanceFactory.*;
	
	
	public class DisplayObjectAsset extends NativeAsset implements IDisplayAsset {
		/**
		 * @inheritDoc
		 */
		public function get addedToStage():IAct {
			return _addedToStage;
		}
		/**
		 * @inheritDoc
		 */
		public function get removedFromStage():IAct {
			if(!_removedFromStage)
				_removedFromStage = new Act();
			return _removedFromStage;
		}
		/**
		 * @inheritDoc
		 */
		public function get added():IAct {
			if(!_added)
				_added = new NativeAct(_displayObject, Event.ADDED, [this]);
			return _added;
		}
		/**
		 * @inheritDoc
		 */
		public function get removed():IAct {
			if(!_removed)
				_removed = new NativeAct(_displayObject, Event.REMOVED, [this]);
			return _removed;
		}
		/**
		 * @inheritDoc
		 */
		public function get enterFrame():IAct {
			if(!_enterFrame)
				_enterFrame = new NativeAct(_displayObject, Event.ENTER_FRAME, [this]);
			return _enterFrame;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get stageChanged():IAct{
			if(!_stageChanged)_stageChanged = new Act();
			return _stageChanged;
		}
		
		override internal function get display():*{
			return displayObject;
		}
		override internal function set display(value:*):void{
			displayObject = value as DisplayObject;
		}
		
		
		public function get displayObject():DisplayObject {
			return _displayObject;
		}
		
		
		public function set displayObject(value:DisplayObject):void {
			if(_displayObject!=value) {
				if(_displayObject) {
					if(_isAddedToStage){
						_isAddedToStage = false;
						if(_removedFromStage)_removedFromStage.perform(this);
					}
					_innerBounds = null;
					_displayObject.scaleX = _origScaleX;
					_displayObject.scaleY = _origScaleY;
					_displayObject.removeEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
				}
				_displayObject = value;
				if(_addedToStage)
					_addedToStage.eventDispatcher = value;
				
				if(_added)
					_added.eventDispatcher = value;
				
				if(_removed)
					_removed.eventDispatcher = value;
				
				if(_enterFrame)
					_enterFrame.eventDispatcher = value;
				
				if(_displayObject){
					_displayObject.addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
					if(_displayObject.stage){
						_isAddedToStage = true;
						if(_addedToStage)_addedToStage.perform(this);
					}
				}
			}
		}
		
		
		private var _stageChanged:Act;
		private var _addedToStage:NativeAct;
		private var _removedFromStage:Act;
		private var _added:NativeAct;
		private var _removed:NativeAct;
		private var _enterFrame:NativeAct;
		
		private var _displayObject:DisplayObject;
		
		protected var _innerBounds:Rectangle;
		protected var _origScaleX:Number;
		protected var _origScaleY:Number;
		
		protected var _isAddedToStage:Boolean;
		protected var _parent:IContainerAsset;
		protected var _stageAsset:IStageAsset;
		
		
		public function DisplayObjectAsset(factory:NativeAssetFactory=null){
			super(factory);
			
			_addedToStage = new NativeAct(null, Event.ADDED_TO_STAGE, [this],false);
			_addedToStage.addHandler(onAddedToStage);
		}
		protected function onAddedToStage(from:DisplayObjectAsset):void{
			_isAddedToStage = true;
			if(_stageChanged)_stageChanged.perform(this);
		}
		protected function onRemovedFromStage(e:Event=null):void{
			if(_removedFromStage)_removedFromStage.perform(this);
			_isAddedToStage = false;
			_stageAsset = null;
			if(_stageChanged)_stageChanged.perform(this);
		}
		
		
		public function get naturalWidth():Number {
			checkInnerBounds();
			return _innerBounds.width*_origScaleX;
		}
		public function get naturalHeight():Number {
			checkInnerBounds();
			return _innerBounds.height*_origScaleY;
		}
		public function get mouseX():Number {
			checkInnerBounds();
			return(_displayObject.mouseX-_innerBounds.x)/_displayObject.scaleX;
		}
		public function get mouseY():Number {
			checkInnerBounds();
			return(_displayObject.mouseY-_innerBounds.y)/_displayObject.scaleY;
		}
		public function set visible(value:Boolean):void {
			_displayObject.visible = value;
		}
		public function get visible():Boolean {
			return _displayObject.visible;
		}
		public function set name(value:String):void {
			_displayObject.name = value;
		}
		public function get name():String {
			return _displayObject.name;
		}
		public function set alpha(value:Number):void {
			_displayObject.alpha = value;
		}
		public function get alpha():Number {
			return _displayObject.alpha;
		}
		public function set blendMode(value:String):void {
			_displayObject.blendMode = value;
		}
		public function get blendMode():String {
			return _displayObject.blendMode;
		}
		public function set x(value:Number):void {
			_displayObject.x = value;
			//_x = value;
			//applyX();
		}
		public function get x():Number {
			//takeX();
			//return _x;
			return _displayObject.x;
		}
		public function set y(value:Number):void {
			//_y = value;
			//applyY();
			_displayObject.y = value;
		}
		public function get y():Number {
			//takeY();
			//return _y;
			return _displayObject.y;
		}
		public function set scrollRect(value:Rectangle):void {
			_displayObject.scrollRect = value;
			//applyX();
			//applyY();
		}
		public function get scrollRect():Rectangle {
			return _displayObject.scrollRect;
		}
		public function set width(value:Number):void {
			if(checkInnerBounds()) {
				_displayObject.width = value;
			} else {
				_displayObject.scaleX = 1;
			}
			//applyX();
		}
		public function get width():Number {
			return _displayObject.width;
		}
		public function set scaleX(value:Number):void {
			_displayObject.scaleX = value;
			//applyX();
		}
		public function get scaleX():Number {
			return _displayObject.scaleX;
		}
		public function set scaleY(value:Number):void {
			_displayObject.scaleY = value;
			//applyX();
		}
		public function get scaleY():Number {
			return _displayObject.scaleY;
		}
		public function set rotation(value:Number):void {
			_displayObject.rotation = value;
		}
		public function get rotation():Number {
			return _displayObject.rotation;
		}
		public function get transform():Transform {
			return _displayObject.transform;
		}
		public function get bitmapDrawable():IBitmapDrawable {
			return _displayObject;
		}
		
		
		public function set height(value:Number):void {
			if(checkInnerBounds()) {
				_displayObject.height = value;
			} else {
				_displayObject.scaleY = 1;
			}
			//applyY();
		}
		
		
		public function get height():Number {
			return _displayObject.height;
		}
		
		
		public function get parent():IContainerAsset {
			return _parent;
		}
		public function set parent(value:IContainerAsset):void {
			_parent = value;
			if(!value){
				if(_addedToStage)onRemovedFromStage();
			}else{
				if(_parent.stage){
					if(!_addedToStage)onAddedToStage(this);
				}else if(_addedToStage)onRemovedFromStage();
			}
		}
		public function get stage():IStageAsset {
			if(_parent && !_stageAsset && _isAddedToStage){
				var topParent:IContainerAsset = _parent;
				while(topParent.parent){
					topParent = topParent.parent;
				}
				_stageAsset = (topParent as IStageAsset);
			}
			return _stageAsset;
		}
		
		protected function checkInnerBounds():Boolean {
			if(_innerBounds){
				return true;
			}
			if(_displayObject) {
				_innerBounds = _displayObject.getBounds(_displayObject);
				_origScaleX = _displayObject.scaleX;
				_origScaleY = _displayObject.scaleY;
				return true;
			}else{
				return false;
			}
		}
		
		public function setPosition(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
		}
		public function setSize(width:Number, height:Number):void {
			this.width = width;
			this.height = height;
		}
		public function setSizeAndPos(x:Number, y:Number, width:Number, height:Number):void {
			setPosition(x,y);
			setSize(width,height);
		}
		
		
		public function globalToLocal(point:Point):Point {
			return _displayObject.globalToLocal(point);
		}
		public function localToGlobal(point:Point):Point {
			return _displayObject.localToGlobal(point);
		}
		public function getBounds(space:IDisplayAsset):Rectangle {
			return _displayObject.getBounds(space.displayObject || space.bitmapDrawable as DisplayObject);
		}
		
		public function getCloneFactory():IInstanceFactory{
			return _nativeFactory.getCloneFactory(this);
		}
		override public function reset():void {
			//_forceTopLeft = true;
			super.reset();
		}
	}
}