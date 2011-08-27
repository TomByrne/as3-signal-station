package org.tbyrne.display.assets.nativeAssets {
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.acts.NativeAct;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.instanceFactory.*;
	
	
	public class DisplayObjectAsset extends NativeAsset implements IDisplayObject, INativeAsset {
		/**
		 * @inheritDoc
		 */
		public function get addedToStage():IAct {
			if(!_addedToStage)
				_addedToStage = new Act();
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
				_enterFrame = new NativeAct(_displayObject, Event.ENTER_FRAME, [this], false);
			return _enterFrame;
		}
		/**
		 * @inheritDoc
		 */
		/*public function get exitFrame():IAct {
			if(!_exitFrame)
				_exitFrame = new NativeAct(_displayObject, Event.EXIT_FRAME, [this], false);
			return _exitFrame;
		}*/
		
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
		
		
		public function get displayObject():DisplayObject{
			return _displayObject;
		}
		public function set displayObject(value:DisplayObject):void {
			if(_displayObject!=value) {
				if(_displayObject) {
					setAddedToStage(false);
					_innerBounds = null;
					_displayObject.scaleX = _origScaleX;
					_displayObject.scaleY = _origScaleY;
					_displayObject.removeEventListener(Event.ADDED_TO_STAGE,handleAddedToStage);
					_displayObject.removeEventListener(Event.REMOVED_FROM_STAGE,handleRemovedToStage);
					if(_noFilters){
						returnFilters();
					}
				}
				_displayObject = value;
				super.display = value;
				
				if(_added)
					_added.eventDispatcher = value;
				
				if(_removed)
					_removed.eventDispatcher = value;
				
				if(_enterFrame)
					_enterFrame.eventDispatcher = value;
				
				/*if(_exitFrame)
					_exitFrame.eventDispatcher = value;*/
				
				if(_displayObject){
					_filters = _displayObject.filters;
					if(_noFilters){
						removeFilters();
					}
					_displayObject.addEventListener(Event.ADDED_TO_STAGE,handleAddedToStage);
					_displayObject.addEventListener(Event.REMOVED_FROM_STAGE,handleRemovedToStage);
					if(_displayObject.stage){
						setAddedToStage(true);
					}
				}
			}
		}
		override public function set noFilters(value:Boolean):void{
			super.noFilters = value;
			if(_displayObject){
				if(_noFilters){
					removeFilters();
				}else{
					returnFilters();
				}
			}
		}
		
		
		private var _stageChanged:Act;
		private var _addedToStage:Act;
		private var _removedFromStage:Act;
		
		private var _added:NativeAct;
		private var _removed:NativeAct;
		private var _enterFrame:NativeAct;
		//private var _exitFrame:NativeAct;
		
		private var _displayObject:DisplayObject;
		
		protected var _innerBounds:Rectangle;
		protected var _origScaleX:Number;
		protected var _origScaleY:Number;
		
		protected var _parent:IDisplayObjectContainer;
		protected var _mask:IDisplayObject;
		
		private var _filters:Array;
		
		
		public function DisplayObjectAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
		private function handleAddedToStage(e:Event=null):void{
			setAddedToStage(true);
		}
		private function handleRemovedToStage(e:Event=null):void{
			setAddedToStage(false);
		}
		protected function setAddedToStage(value:Boolean):void{
			if(_isAddedToStage!=value){
				if(!value){
					// call this before setting isAddedToStage to allow stage getter to work from handlers.
					onRemovedFromStage();
					if(_stageChanged)_stageChanged.perform(this);
				}
				_isAddedToStage = value;
				if(value){
					onAddedToStage();
					if(_stageChanged)_stageChanged.perform(this);
					if(_addedToStage)_addedToStage.perform(this);
				}
			}
		}
		
		
		protected function onAddedToStage():void{
			_isAddedToStage = true;
		}
		protected function onRemovedFromStage():void{
			if(_removedFromStage)_removedFromStage.perform(this);
			_isAddedToStage = false;
			_stageAsset = null;
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
		public function set scrollRect(value:Rectangle):void {
			if(pixelSnapping && value){
				value.x = round(value.x);
				value.y = round(value.y);
				value.width = round(value.x+value.width)-value.x;
				value.height = round(value.y+value.height)-value.y;
			}
			_displayObject.scrollRect = value;
		}
		public function get scrollRect():Rectangle {
			return _displayObject.scrollRect;
		}
		public function set scaleX(value:Number):void {
			_displayObject.scaleX = value;
			if(pixelSnapping){
				var setWas:Boolean = _widthSet;
				_widthSet = true;
				_width = _displayObject.width;
				setPixelWidth();
				_widthSet = setWas;
			}
		}
		public function get scaleX():Number {
			return _displayObject.scaleX;
		}
		public function set scaleY(value:Number):void {
			_displayObject.scaleY = value;
			if(pixelSnapping){
				var setWas:Boolean = _heightSet;
				_heightSet = true;
				_height = _displayObject.height;
				setPixelHeight();
				_heightSet = setWas;
			}
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
		
		
		public function get filters():Array{
			return _filters;
		}
		public function set filters(value:Array):void{
			_filters = value;
			if(!_noFilters){
				_displayObject.filters = value;
			}
		}
		
		
		override public function set height(value:Number):void {
			if(checkInnerBounds()) {
				super.height = value;
			} else {
				_displayObject.scaleY = 1;
			}
		}
		override public function set width(value:Number):void {
			if(checkInnerBounds()) {
				super.width = value;
			} else {
				_displayObject.scaleX = 1;
			}
		}
		
		
		public function set mask(value:IDisplayObject):void {
			if(_mask != value){
				_mask = value;
				var castMask:INativeAsset = (value as INativeAsset);
				_displayObject.mask = (castMask?castMask.displayObject:null);
			}
		}
		public function get mask():IDisplayObject {
			if(!_mask && _displayObject.mask){
				_mask = _nativeFactory.getNew(_displayObject.mask);
			}
			return _mask;
		}
		
		public function get parent():IDisplayObjectContainer {
			if(_isAddedToStage && !_parent && !(this is IStage)){
				_parent = _nativeFactory.getNew(_displayObject.parent);
			}
			return _parent;
		}
		public function set parent(value:IDisplayObjectContainer):void {
			if(_parent != value){
				_parent = value;
				if(!value){
					setAddedToStage(false);
				}else{
					if(_parent.stage) setAddedToStage(true);
					else setAddedToStage(false);
				}
			}
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
		public function getBounds(space:IDisplayObject):Rectangle {
			var nativeAsset:INativeAsset = (space as INativeAsset);
			return _displayObject.getBounds(nativeAsset.displayObject || space.bitmapDrawable as DisplayObject);
		}
		
		public function getCloneFactory():IInstanceFactory{
			return _nativeFactory.getCloneFactory(this);
		}
		override public function reset():void {
			//_forceTopLeft = true;
			super.reset();
		}
		
		
		override protected function findStageRef():IStage{
			if(_parent){
				var parentStage:IStage = _parent.stage;
				if(parentStage)return parentStage;
			}
			return super.findStageRef();
		}
		
		
		protected function removeFilters():void{
			if(_displayObject.filters && _displayObject.filters.length){
				_displayObject.filters = null;
			}
		}
		
		
		protected function returnFilters():void{
			if(_filters && _filters.length){
				_displayObject.filters = _filters;
			}
		}
	}
}