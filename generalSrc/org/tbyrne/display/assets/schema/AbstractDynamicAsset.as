package org.tbyrne.display.assets.schema
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.acts.NativeAct;
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.IAssetFactory;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeAssets.INativeAsset;
	import org.tbyrne.display.assets.nativeAssets.actInfo.KeyActInfo;
	import org.tbyrne.display.assets.nativeAssets.actInfo.MouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.*;
	import org.tbyrne.display.assets.schemaTypes.*;
	import org.tbyrne.display.assets.utils.isDescendant;
	
	public class AbstractDynamicAsset extends AbstractSchemaBasedAsset implements ISprite, ITextField, IBitmap, INativeAsset
	{
		private static var DISPLAY_MAP:Dictionary = new Dictionary();
		
		/*public function get forceTopLeft():Boolean {
			return _forceTopLeft;
		}
		public function set forceTopLeft(value:Boolean):void{
			if(_forceTopLeft!=value){
				_forceTopLeft = value;
				redrawSize();
			}
		}*/
		
		protected var _rect:Shape;
		protected var _textField:TextField;
		protected var _displayObject:DisplayObject;
		protected var _sprite:Sprite;
		protected var _interactiveObject:InteractiveObject;
		protected var _bitmap:Bitmap;
		
		private var _displaySchema:IDisplayAssetSchema;
		private var _naturalWidth:Number;
		private var _naturalHeight:Number;
		private var _rectVisible:Boolean;
		
		private var eventBundles:Array;
		
		public function AbstractDynamicAsset(factory:IAssetFactory=null, schema:IAssetSchema=null){
			super(factory, schema);
			
			_addedToStage = new NativeAct(_displayObject, Event.ADDED_TO_STAGE, [this],false);
			_addedToStage.addHandler(onAddedToStage);
			
			setupActBundles();
		}
		override public function conformsToType(type:Class):Boolean{
			switch(type){
				case ITextField:
					return (_textField!=null);
				case IBitmap:
					return (_bitmap!=null);
				case IInteractiveObject:
					return (_interactiveObject!=null);
				case ISprite:
				case IDisplayObjectContainer:
					return (_sprite!=null);
				case IDisplayObject:
					return (_displayObject!=null);
			}
			return super.conformsToType(type);
		}
		
		protected function setupActBundles():void{
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
				new EventBundle(KeyboardEvent.KEY_DOWN, "_keyDown", onKeyEvent),
				new EventBundle(KeyboardEvent.KEY_UP, "_keyUp", onKeyEvent),
				new EventBundle(Event.CHANGE, "_change", onTextChange)];
		}
		protected function onAddedToStage(from:AbstractDynamicAsset):void{
			_isAddedToStage = true;
			if(_stageChanged)_stageChanged.perform(this);
		}
		protected function onRemovedFromStage(e:Event=null):void{
			if(_removedFromStage)_removedFromStage.perform(this);
			_isAddedToStage = false;
			_stage = null;
			if(_stageChanged)_stageChanged.perform(this);
		}
		override protected function addSchema():void{
			_displaySchema = schema as IDisplayAssetSchema;
			_naturalWidth = 0;
			_naturalHeight = 0;
			var textSchema:ITextAssetSchema = schema as ITextAssetSchema;
			if(textSchema){
				_textField = new TextField();
				_textField.selectable = false;
				_textField.width = _naturalWidth = textSchema.width;
				_textField.height = _naturalHeight = textSchema.height;
				if(textSchema.initialText)_textField.htmlText = textSchema.initialText;
				_displayObject = _textField;
				_interactiveObject = _textField;
			}else{
				var bitmapSchema:IBitmapAssetSchema = schema as IBitmapAssetSchema;
				if(bitmapSchema){
					_bitmap = new Bitmap();
					_displayObject = _bitmap;
					_naturalWidth = bitmapSchema.width;
					_naturalHeight = bitmapSchema.height;
				}else{
					var contSchema:IContainerAssetSchema = schema as IContainerAssetSchema;
					var rectSchema:IRectangleAssetSchema = schema as IRectangleAssetSchema;
					if(contSchema){
						_sprite = new Sprite();
						_displayObject = _sprite;
						_interactiveObject = _sprite;
						if(rectSchema){
							// this allows the shape the be stretched without affecting the children
							_rect = new Shape();
							_sprite.addChild(_rect);
						}
					}else{
						var shape:Shape = new Shape();
						_displayObject = shape;
						if(rectSchema)_rect = shape;
					}
					if(rectSchema){
						_rectVisible = rectSchema.visible;
						drawRect(_rect,rectSchema.width,rectSchema.height,_rectVisible);
						_naturalWidth = rectSchema.width;
						_naturalHeight = rectSchema.height;
					}
				}
			}
			_displayObject.x = _displaySchema.x;
			_displayObject.y = _displaySchema.y;
			if(_displaySchema.assetName)_displayObject.name = _displaySchema.assetName;
			
			_addedToStage.eventDispatcher = _displayObject;
			
			_displayObject.addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
			
			if(_added)
				_added.eventDispatcher = _displayObject;
			
			if(_removed)
				_removed.eventDispatcher = _displayObject;
			
			if(_enterFrame)
				_enterFrame.eventDispatcher = _displayObject;
			
			if(_exitFrame)
				_exitFrame.eventDispatcher = _displayObject;
			
			// this is disabled because we're assuming that if the schema is being changed
			// then event handlers shouldn't be renewed, they'll be renewed when the Acts are
			// accessed.
			/*if(_interactiveObject){
				for each(var bundle:EventBundle in eventBundles){
					if(this[bundle.actName]){
						bundle.listening = true;
						_interactiveObject.addEventListener(bundle.eventName, bundle.handler);
					}
				}
			}*/
			
			_width = _displayObject.width;
			_height = _displayObject.height;
			
			_displayObject.addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
			DISPLAY_MAP[_displayObject] = this;
		}
		override protected function removeSchema():void{
			_displaySchema = null;
			_displayObject.removeEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
			
			delete DISPLAY_MAP[_displayObject];
			
			_width = NaN;
			_height = NaN;
			
			_addedToStage.eventDispatcher = null;
			
			_displayObject.removeEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
			
			if(_added)
				_added.eventDispatcher = null;
			
			if(_removed)
				_removed.eventDispatcher = null;
			
			if(_enterFrame)
				_enterFrame.eventDispatcher = null;
			
			if(_exitFrame)
				_exitFrame.eventDispatcher = null;
			
			removeAllChildren();
			
			for each(var bundle:EventBundle in eventBundles){
				if(bundle.listening){
					bundle.listening = false;
					_displayObject.removeEventListener(bundle.eventName, bundle.handler);
				}
			}
			
			_textField = null;
			_displayObject = null;
			_bitmap = null;
			_sprite = null;
			_rect = null;
			_interactiveObject = null;
		}
		protected function redrawSize():void{
			if(_textField){
				sizeTextField(_textField, _width, _height);
			}
			if(_rect){
				drawRect(_rect,_width,_height,_rectVisible);
			}
		}
		protected function redrawPosition():void{
			// override me
			_displayObject.x = _x;
			_displayObject.y = _y;
		}
		protected function sizeTextField(textField:TextField, width:Number, height:Number):void{
			// override me
			textField.width = width;
			textField.height = height;
		}
		protected function drawRect(rect:Shape, width:Number, height:Number, visible:Boolean):void{
			// override me
			rect.graphics.clear();
			if(!isNaN(width) && !isNaN(height)){
				if(visible)rect.graphics.lineStyle(0,0);
				rect.graphics.beginFill(0xffffff,visible?1:0);
				rect.graphics.drawRect(0,0,width,height);
				rect.graphics.endFill();
				rect.scaleX = 1;
				rect.scaleY = 1;
			}
		}
		public function addChildren(array:Array):void{
			for each(var child:IDisplayObject in array){
				addAsset(child);
			}
		}
		protected function confirmListening(eventName:String):void{
			var bundle:EventBundle = findBundle(eventName);
			if(!bundle.listening){
				bundle.listening = true;
				_displayObject.addEventListener(bundle.eventName, bundle.handler);
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
		
		
		/*
				IDisplayObject implementation
		*/
		
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
				_enterFrame = new NativeAct(_displayObject, Event.ENTER_FRAME, [this], false);
			return _enterFrame;
		}
		/**
		 * @inheritDoc
		 */
		public function get exitFrame():IAct {
			if(!_exitFrame)
				_exitFrame = new NativeAct(_displayObject, Event.EXIT_FRAME, [this], false);
			return _exitFrame;
		}
		/**
		 * @inheritDoc
		 */
		public function get stageChanged():IAct{
			if(!_stageChanged)_stageChanged = new Act();
			return _stageChanged;
		}
		
		protected var _x:Number;
		protected var _y:Number;
		protected var _width:Number;
		protected var _height:Number;
		//protected var _forceTopLeft:Boolean = true;
		
		protected var _isAddedToStage:Boolean;
		protected var _parent:IDisplayObjectContainer;
		protected var _stage:IStage;
		protected var _mask:IDisplayObject;
		
		protected var _stageChanged:Act;
		protected var _enterFrame:NativeAct;
		protected var _exitFrame:NativeAct;
		protected var _removed:NativeAct;
		protected var _added:NativeAct;
		protected var _removedFromStage:Act;
		protected var _addedToStage:NativeAct;
		
		
		public function get displayObject():DisplayObject {
			return _displayObject;
		}
		public function set x(value:Number):void {
			if(_x!=value){
				_x = value;
				redrawPosition();
			}
		}
		public function get x():Number{return _displayObject.x};
		
		public function set y(value:Number):void {
			if(_y!=value){
				_y = value;
				redrawPosition();
			}
		}
		public function get y():Number{return _displayObject.y};
		
		public function set width(value:Number):void {
			if(_width!=value){
				_width = value;
				redrawSize();
			}
		}
		public function get width():Number{return _width};
		
		public function set height(value:Number):void {
			if(_height!=value){
				_height = value;
				redrawSize();
			}
		}
		public function get height():Number{return _height};
		
		
		public function setPosition(x:Number, y:Number):void{
			if(_x!=x || _y!=y){
				_x = x;
				_y = y;
				redrawPosition();
			}
		}
		public function setSize(width:Number, height:Number):void{
			if(_width!=width || _height!=height){
				_width = width;
				_height = height;
				redrawSize();
			}
		}
		public function setSizeAndPos(x:Number, y:Number, width:Number, height:Number):void{
			setPosition(x,y);
			setSize(width,height);
		}
		
		
		public function set scaleX(value:Number):void {_displayObject.scaleX = value;}
		public function get scaleX():Number{return _displayObject.scaleX};
		
		public function set scaleY(value:Number):void {_displayObject.scaleY = value;}
		public function get scaleY():Number{return _displayObject.scaleY};
		
		public function set rotation(value:Number):void{_displayObject.rotation = value};
		public function get rotation():Number{return _displayObject.rotation};
		
		public function get mouseX():Number{return _displayObject.mouseX}
		public function get mouseY():Number{return _displayObject.mouseY}
		
		public function get naturalWidth():Number{return _naturalWidth}
		public function get naturalHeight():Number{return _naturalHeight}
		
		public function set visible(value:Boolean):void{_displayObject.visible = value};
		public function get visible():Boolean{return _displayObject.visible};
		
		public function set name(value:String):void{_displayObject.name = value};
		public function get name():String{return _displayObject.name};
		
		public function set alpha(value:Number):void{_displayObject.alpha = value};
		public function get alpha():Number{return _displayObject.alpha};
		
		public function set blendMode(value:String):void{_displayObject.blendMode = value};
		public function get blendMode():String{return _displayObject.blendMode};
		
		public function set filters(value:Array):void{_displayObject.filters = value};
		public function get filters():Array{return _displayObject.filters};
		
		public function set scrollRect(value:Rectangle):void{_displayObject.scrollRect = value;}
		public function get scrollRect():Rectangle{return _displayObject.scrollRect};
		
		public function get transform():Transform{return _displayObject.transform};
		
		public function get bitmapDrawable():IBitmapDrawable{return _displayObject};
		
		
		public function set mask(value:IDisplayObject):void {
			if(_mask != value){
				_mask = value;
				var castMask:INativeAsset = (value as INativeAsset);
				_displayObject.mask = (castMask?castMask.displayObject:null);
			}
		}
		public function get mask():IDisplayObject {
			return _mask;
		}
		public function get parent():IDisplayObjectContainer {
			return _parent;
		}
		public function set parent(value:IDisplayObjectContainer):void {
			_parent = value;
			if(!value)_stage = null;
		}
		public function get stage():IStage {
			if(_isAddedToStage && !_stage){
				var topParent:IDisplayObjectContainer = _parent;
				while(topParent.parent){
					topParent = topParent.parent;
				}
				_stage = (topParent as IStage);
			}
			return _stage;
		}
		
		public function position(x:Number, y:Number, width:Number, height:Number):void {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		public function globalToLocal(point:Point):Point {
			return _displayObject.globalToLocal(point);
		}
		public function localToGlobal(point:Point):Point {
			return _displayObject.localToGlobal(point);
		}
		public function getBounds(space:IDisplayObject):Rectangle {
			var nativeAsset:INativeAsset = (space as INativeAsset);
			if(nativeAsset){
				return _displayObject.getBounds(nativeAsset.displayObject || space.bitmapDrawable as DisplayObject);
			}else{
				return null;
			}
		}
		
		
		
		/*
				IInteractiveObject implementation
		*/
		
		protected var _focusIn:NativeAct;
		protected var _focusOut:NativeAct;
		
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
		protected var _keyDown:Act;
		protected var _keyUp:Act;
		
		
		/**
		 * @inheritDoc
		 */
		public function get mouseReleased():IAct{
			if(!_mouseDown)_mouseDown = new Act();
			confirmListening(MouseEvent.MOUSE_DOWN);
			return _mouseDown;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mousePressed():IAct{
			if(!_mouseUp)_mouseUp = new Act();
			confirmListening(MouseEvent.MOUSE_UP);
			return _mouseUp;
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
			if(!_focusIn)_focusIn = new NativeAct(_interactiveObject,FocusEvent.FOCUS_IN,[this], false);
			return _focusIn;
		}
		/**
		 * @inheritDoc
		 */
		public function get focusOut():IAct{
			if(!_focusOut)_focusOut = new NativeAct(_interactiveObject,FocusEvent.FOCUS_OUT,[this], false);
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
		
		public function get tabEnabled():Boolean{return _interactiveObject.tabEnabled};
		public function set tabEnabled(value:Boolean):void{_interactiveObject.tabEnabled = value};
		
		public function get mouseEnabled():Boolean{return _interactiveObject.mouseEnabled};
		public function set mouseEnabled(value:Boolean):void{_interactiveObject.mouseEnabled = value};
		
		public function get doubleClickEnabled():Boolean{return _interactiveObject.doubleClickEnabled};
		public function set doubleClickEnabled(value:Boolean):void{_interactiveObject.doubleClickEnabled = value};
		
		public function get tabIndex():int{return _interactiveObject.tabIndex};
		public function set tabIndex(value:int):void{_interactiveObject.tabIndex = value};
		
		public function get focusRect():Object{return _interactiveObject.focusRect};
		public function set focusRect(value:Object):void{_interactiveObject.focusRect = value};
		
		private function onMouseEvent(e:MouseEvent):void{
			var act:Act = this["_"+e.type];
			if(act){
				act.perform(this,createMouseInfo(e));
			}
		}
		private function onMouseWheel(e:MouseEvent):void{
			if(_mouseWheel)_mouseWheel.perform(this,createMouseInfo(e),e.delta);
		}
		protected function createMouseInfo(e:MouseEvent):IMouseActInfo{
			var target:IDisplayObject = (e.target==_interactiveObject?this:DISPLAY_MAP[e.target]);
			return new MouseActInfo(target, e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		
		private function onKeyEvent(e:KeyboardEvent):void{
			var act:Act = this["_"+e.type];
			if(act){
				act.perform(this,createKeyEvent(e));
			}
		}
		protected function createKeyEvent(e:KeyboardEvent):IKeyActInfo{
			var target:IDisplayObject = (e.target==_textField?this:DISPLAY_MAP[e.target]);
			return new KeyActInfo(target, e.altKey, e.ctrlKey, e.shiftKey, e.charCode, e.keyCode, e.keyLocation);
		}
		
		
		/*
				IDisplayObjectContainer implementation
		*/
		
		private var _children:Dictionary = new Dictionary();
		
		override protected function _addStateList(stateList:Array):void{
			super._addStateList(stateList);
			if(_sprite){
				for each(var child:IDisplayObject in _children){
					child.addStateList(stateList,true);
				}
			}
		}
		override protected function _removeStateList(stateList:Array):void{
			super._removeStateList(stateList);
			if(_sprite){
				for each(var child:IDisplayObject in _children){
					child.removeStateList(stateList);
				}
			}
		}
		public function takeAssetByName(name:String, optional:Boolean=false):*{
			var display:DisplayObject = _sprite.getChildByName(name);
			var ret:AbstractDynamicAsset =  _children[display];
			if(!ret && _schema.fallbackToGroup){
				ret = _schemaFactory.getCoreSkin(name) as AbstractDynamicAsset;
				if(ret){
					addAsset(ret);
				}
			}
			if(!ret && !optional){
				Log.error( "AbstractDynamicAsset.takeAssetByName: Child with name "+name+" not found");
			}else{
				return ret;
			}
		}
		public function returnAsset(asset:IDisplayObject):void{
			// ignore
		}
		
		public function addAsset(asset:IDisplayObject):void{
			var nativeAsset:INativeAsset = (asset as INativeAsset);
			CONFIG::debug{
				if(!asset)Log.error("no asset provided");
				if(!nativeAsset)Log.error("cannot add non-native asset");
				if(_children[nativeAsset.displayObject])Log.error("asset already added (AbstractDynamicAsset.addAsset).");
			}
			asset.parent = this;
			_sprite.addChild(nativeAsset.displayObject);
			_children[nativeAsset.displayObject] = asset;
			for each(var stateList:Array in _stateLists){
				asset.addStateList(stateList,true);
			}
		}
		public function addAssetAt(asset:IDisplayObject, index:int):IDisplayObject{
			var nativeAsset:INativeAsset = (asset as INativeAsset);
			asset.parent = this;
			_sprite.addChildAt(nativeAsset.displayObject,index);
			_children[nativeAsset.displayObject] = asset;
			for each(var stateList:Array in _stateLists){
				asset.addStateList(stateList,true);
			}
			return asset;
		}
		public function removeAsset(asset:IDisplayObject):void{
			var nativeAsset:INativeAsset = (asset as INativeAsset);
			for each(var stateList:Array in _stateLists){
				asset.removeStateList(stateList);
			}
			asset.parent = null;
			_sprite.removeChild(nativeAsset.displayObject);
			delete _children[nativeAsset.displayObject];
		}
		
		public function containsAssetByName(name:String):Boolean{
			var display:DisplayObject = _sprite.getChildByName(name);
			return _children[display]!=null;
		}
		public function contains(child:IDisplayObject):Boolean{
			var nativeAsset:INativeAsset = (child as INativeAsset);
			if(_children[nativeAsset.displayObject] || child==this){
				return true;
			}else if(_sprite){
				var cast:INativeAsset = (child as INativeAsset);
				if(cast){
					return _sprite.contains(cast.displayObject);
				}
			}
			return isDescendant(this,child);
		}
		
		public function getAssetIndex(asset:IDisplayObject):int{
			var nativeAsset:INativeAsset = (asset as INativeAsset);
			return _sprite.getChildIndex(nativeAsset.displayObject);
		}
		public function setAssetIndex(asset:IDisplayObject, index:int):void{
			var nativeAsset:INativeAsset = (asset as INativeAsset);
			_sprite.setChildIndex(nativeAsset.displayObject,index);
		}
		public function getAssetAt(index:int):IDisplayObject{
			var display:DisplayObject = _sprite.getChildAt(index);
			return _children[display];
		}
		
		public function get mouseChildren():Boolean{return _sprite.mouseChildren}
		public function set mouseChildren(value:Boolean):void{_sprite.mouseChildren = value}
		
		public function get numChildren():int{return _sprite.numChildren}
		
		public function removeAllChildren():void{
			for each(var child:IDisplayObject in _children){
				var nativeAsset:INativeAsset = (child as INativeAsset);
				for each(var stateList:Array in _stateLists){
					child.removeStateList(stateList);
				}
				child.parent = null;
				_sprite.removeChild(nativeAsset.displayObject);
			}
			_children = new Dictionary();
		}
		
		
		
		/*
		ISprite implementation
		*/
		
		private var _hitArea:ISprite
		
		public function get useHandCursor():Boolean{return _sprite.useHandCursor}
		public function set useHandCursor(value:Boolean):void{_sprite.useHandCursor = value}
		
		public function get buttonMode():Boolean{return _sprite.buttonMode}
		public function set buttonMode(value:Boolean):void{_sprite.buttonMode = value}
		
		public function get hitArea():ISprite{
			return _hitArea;
		}
		public function set hitArea(value:ISprite):void{
			var nativeAsset:INativeAsset = (value as INativeAsset);
			_hitArea = value;
			if(value && nativeAsset){
				_sprite.hitArea = nativeAsset.displayObject as Sprite;
			}else{
				_sprite.hitArea = null;
			}
		}
		
		
		/*
			ITextField implementation
		*/
		
		protected var _change:Act;
		
		public function set text(value:String):void{_textField.text = value}
		public function get text():String{return _textField.text}
		
		public function set type(value:String):void{_textField.type = value}
		public function get type():String{return _textField.type}
		
		public function set restrict(value:String):void{_textField.restrict = value}
		public function get restrict():String{return _textField.restrict}
		
		public function set maxChars(value:int):void{_textField.maxChars = value}
		public function get maxChars():int{return _textField.maxChars}
		
		public function set htmlText(value:String):void{_textField.htmlText = value}
		public function get htmlText():String{return _textField.htmlText}
		
		public function set multiline(value:Boolean):void{_textField.multiline = value}
		public function get multiline():Boolean{return _textField.multiline}
		
		public function set wordWrap(value:Boolean):void{_textField.wordWrap = value}
		public function get wordWrap():Boolean{return _textField.wordWrap}
		
		public function set displayAsPassword(value:Boolean):void{_textField.displayAsPassword = value}
		public function get displayAsPassword():Boolean{return _textField.displayAsPassword}
		
		public function set selectable(value:Boolean):void{_textField.selectable = value}
		public function get selectable():Boolean{return _textField.selectable}
		
		public function set defaultTextFormat(value:TextFormat):void{_textField.defaultTextFormat = value}
		public function get defaultTextFormat():TextFormat{return _textField.defaultTextFormat}
		
		public function set border(value:Boolean):void{_textField.border = value}
		public function get border():Boolean{return _textField.border}
		
		public function set autoSize(value:String):void{_textField.autoSize = value}
		public function get autoSize():String{return _textField.autoSize}
		
		public function get selectionBeginIndex():int{return _textField.selectionBeginIndex}
		public function get selectionEndIndex():int{return _textField.selectionEndIndex}
		
		public function set embedFonts(value:Boolean):void{_textField.embedFonts = value}
		public function get embedFonts():Boolean{return _textField.embedFonts}
		
		public function get textWidth():Number{return _textField.textWidth}
		public function get textHeight():Number{return _textField.textHeight}
		public function get maxScrollV():int{return _textField.maxScrollV}
		public function get maxScrollH():int{return _textField.maxScrollH}
		public function get bottomScrollV():int{return _textField.bottomScrollV}
		
		/**
		 * @inheritDoc
		 */
		public function get change():IAct{
			if(!_change)_change = new Act();
			confirmListening(Event.CHANGE);
			return _change;
		}
		
		
		private function onTextChange(e:Event):void{
			_change.perform(e,this);
		}
		public function setTextFormat(format:TextFormat, beginIndex:int  = -1, endIndex:int  = -1):void{
			_textField.setTextFormat(format,beginIndex,endIndex);
		}
		public function setSelection(beginIndex:int, endIndex:int):void{
			_textField.setSelection(beginIndex, endIndex);
		}
		public function appendText(text:String):void{
			_textField.appendText(text);
		}
		public function getCharIndexAtPoint(x:Number, y:Number):int{
			return _textField.getCharIndexAtPoint(x, y);
		}
		public function getCharBoundaries(charIndex:int):Rectangle{
			return _textField.getCharBoundaries(charIndex);
		}
		public function getLineMetrics(lineIndex:int):TextLineMetrics{
			return _textField.getLineMetrics(lineIndex);
		}
		
		
		
		/*
			IBitmap implementation
		*/
		
		public function get bitmapData():BitmapData{return _bitmap.bitmapData}
		public function set bitmapData(value:BitmapData):void{_bitmap.bitmapData = value}
		public function get bitmapPixelSnapping():String{return _bitmap.pixelSnapping}
		public function set bitmapPixelSnapping(value:String):void{_bitmap.pixelSnapping = value}
		public function get smoothing():Boolean{return _bitmap.smoothing}
		public function set smoothing(value:Boolean):void{_bitmap.smoothing = value}
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