package org.farmcode.sodalityLibrary.display.visualSockets.sockets
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.core.IOutroView;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodalityLibrary.display.visualSockets.events.DisplaySocketEvent;
	import org.farmcode.sodalityLibrary.display.visualSockets.mappers.IPlugMapper;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;

	[Event(name="plugDisplayChanged",type="org.farmcode.sodalityLibrary.display.visualSockets.events.DisplaySocketEvent")]
	public class DisplaySocket extends EventDispatcher implements IDisplaySocket, ILayoutSubject, IView
	{
		
		/**
		 * @inheritDoc
		 */
		public function get measurementsChanged():IAct{
			if(!_measurementsChanged)_measurementsChanged = new Act();
			return _measurementsChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get assetChanged():IAct{
			if(!_assetChanged)_assetChanged = new Act();
			return _assetChanged;
		}
		
		protected var _assetChanged:Act;
		protected var _measurementsChanged:Act;
		
		protected var _oldMeasX:Number;
		protected var _oldMeasY:Number;
		protected var _oldMeasWidth:Number;
		protected var _oldMeasHeight:Number;
		
		private var _socketId: String;
		private var _socketPath: String;
		private var _displayDepth: int = -1;
		private var _plugMappers: Array;
		private var _advisorPlugMappers: Array;
		private var _plugDisplay: IPlugDisplay;
		private var _container:DisplayObjectContainer;
		private var _displayPosition:Rectangle = new Rectangle();
		private var _introOutroOverlap:Number = 0;
		private var _outroBegunAt:Number;
		private var _outroLength:Number;
		private var _layoutInfo:ILayoutInfo;
		
		private var _lastDisplayObject:DisplayObject;
		private var _lastParent:DisplayObjectContainer;
		private var _lastDepth:int;

		public function DisplaySocket(socketId: String = null, container:DisplayObjectContainer=null, plugMappers:Array=null){
			this.socketId = socketId;
			this.container = container;
			this.plugMappers = plugMappers;
		}
		public function get asset():DisplayObject{
			return _container;
		}
		/*
		globalPosition is currently only used for debugging and is therefore not optimised.
		*/
		public function get globalPosition():Rectangle{
			var tl:Point = _container.localToGlobal(_displayPosition.topLeft);
			var br:Point = _container.localToGlobal(_displayPosition.bottomRight);
			return new Rectangle(tl.x,tl.y,br.x-tl.x,br.y-tl.y);
		}
		
		[Property(toString="true",clonable="true")]
		public function get layoutInfo():ILayoutInfo{
			return _layoutInfo;
		}
		public function set layoutInfo(value:ILayoutInfo):void{
			_layoutInfo = value;
		}
		[Property(toString="true", clonable="true")]
		public function get socketId(): String{
			return this._socketId;
		}
		public function set socketId(value: String): void{
			this._socketId = value;
		}
		[Property(toString="true", clonable="true")]
		public function get socketPath(): String{
			return this._socketPath;
		}
		public function set socketPath(value: String): void{
			this._socketPath = value;
		}
		[Property(toString="true", clonable="true")]
		public function get displayDepth(): int{
			return this._displayDepth;
		}
		public function set displayDepth(value: int): void{
			if(_displayDepth != value){
				this._displayDepth = value;
				if(value!=-1 && _container && _plugDisplay){
					_container.setChildIndex(_plugDisplay.display,value);
				}
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get introOutroOverlap():Number{
			return _introOutroOverlap;
		}
		public function set introOutroOverlap(value:Number):void{
			_introOutroOverlap = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get plugMappers(): Array{
			return this._plugMappers;
		}
		public function set plugMappers(value: Array): void{
			for each(var advisor:INonVisualAdvisor in _advisorPlugMappers){
				advisor.advisorDisplay = null;
			}
			this._plugMappers = value;
			_advisorPlugMappers = [];
			for each(var mapper:IPlugMapper in _plugMappers){
				var cast:INonVisualAdvisor = (mapper as INonVisualAdvisor);
				if(cast && !cast.advisorDisplay){
					cast.advisorDisplay = container;
					_advisorPlugMappers.push(cast);
				}
			}
			
		}
		[Property(toString="true", clonable="true")]
		public function get container(): DisplayObjectContainer{
			return _container;
		}
		public function set container(value: DisplayObjectContainer): void{
			var depth:int = _displayDepth;
			if (_plugDisplay && _container){
				var remDepth:int = removeDisplay(_plugDisplay);
				if(depth==-1){
					depth = remDepth;
				}
			}
			var oldAsset:DisplayObject = _container;
			_container = value;
			if (_plugDisplay && _container){
				addDisplay(_plugDisplay.display, depth);
			}
			for each(var advisor:INonVisualAdvisor in _advisorPlugMappers){
				advisor.advisorDisplay = value;
			}
			if(_assetChanged)_assetChanged.perform(this,oldAsset);
		}
		[Property(toString="true", clonable="true")]
		public function get plugDisplay(): IPlugDisplay{
			return _plugDisplay;
		}
		public function set plugDisplay(value: IPlugDisplay): void{
			if(_plugDisplay!=value){
				var depth:int = _displayDepth;
				if (_plugDisplay){
					if(_plugDisplay.displaySocket==this){
						_plugDisplay.displaySocket = null;
					}
					if(_container && isNaN(_outroBegunAt)){
						var remDepth:int = removeDisplay(_plugDisplay);
						if(depth==-1){
							depth = remDepth;
						}
					}else if(_lastParent){
						_lastParent.addChildAt(_plugDisplay.display,_lastDepth);
					}
					
					_plugDisplay.displayChanged.removeHandler(onDisplayChanged);
					_plugDisplay.measurementsChanged.removeHandler(onPlugMeasChanged);
				}
				_plugDisplay = value;
				if (_plugDisplay){
					_plugDisplay.displaySocket = this; // this must be done before adding to stage
					_lastParent = _plugDisplay.display.parent;
					if(_lastParent){
						_lastDepth = _lastParent.getChildIndex(_plugDisplay.display);
					}
					// call setDisplayPosition before adding the plugDisplay to stage so that it has the correct position for transitioning.
					_plugDisplay.setDisplayPosition(_displayPosition.x,_displayPosition.y,_displayPosition.width,_displayPosition.height);
					if(_container){
						addDisplayAfterDelay(_plugDisplay,depth);
					}
					_plugDisplay.displayChanged.addHandler(onDisplayChanged);
					_plugDisplay.measurementsChanged.addHandler(onPlugMeasChanged);
				}
				dispatchEventIf(DisplaySocketEvent.PLUG_DISPLAY_CHANGED,DisplaySocketEvent);
				dispatchMeasurementChange();
			}
		}
		public function get layoutDisplay():DisplayObject{
			return _plugDisplay?_plugDisplay.display:null;
		}
		public function get displayMeasurements():Rectangle{
			var meas:Rectangle;
			if(_plugDisplay && (meas = _plugDisplay.displayMeasurements)){
				_oldMeasX = meas.x;
				_oldMeasY = meas.y;
				_oldMeasWidth = meas.width;
				_oldMeasHeight = meas.height;
				return meas; 
			}else{
				_oldMeasX = NaN;
				_oldMeasY = NaN;
				_oldMeasWidth = NaN;
				_oldMeasHeight = NaN;
				return null;
			}
		}
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			_displayPosition.x = x;
			_displayPosition.y = y;
			_displayPosition.width = width;
			_displayPosition.height = height;
			if(_plugDisplay)_plugDisplay.setDisplayPosition(x,y,width,height);
		}
		protected function onPlugMeasChanged(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		protected function onDisplayChanged(from:IPlugDisplay, oldDisplay:DisplayObject, newDisplay:DisplayObject):void{
			completeRemoveDisplay(_lastDisplayObject, _container, _lastParent, _lastDepth);
			_lastParent = _plugDisplay.display.parent;
			if(_lastParent)_lastDepth = _lastParent.getChildIndex(_plugDisplay.display);
			else _lastDepth = -1;
			addDisplay(_plugDisplay.display, _displayDepth);
		}
		protected function removeDisplay(plugDisplay:IPlugDisplay):int{
			var depth:int = _container.getChildIndex(plugDisplay.display);
			var cast:IOutroView = plugDisplay as IOutroView;
			if(cast){
				_outroLength = cast.showOutro();
				if(_outroLength){
					_outroBegunAt = getTimer()/1000;
					var delayedCall:DelayedCall = new DelayedCall(completeRemoveDisplay,_outroLength,true,[plugDisplay.display,_container,_lastParent,_lastDepth]);
					delayedCall.begin();
				}else{
					completeRemoveDisplay(plugDisplay.display,_container,_lastParent,_lastDepth);
				}
			}else{
				completeRemoveDisplay(plugDisplay.display,_container,_lastParent,_lastDepth);
			}
			return depth;
		}
		protected function completeRemoveDisplay(displayObject:DisplayObject, container:DisplayObjectContainer, originalParent:DisplayObjectContainer, originalDepth:int):void{
			_outroBegunAt = NaN;
			if(originalParent){
				originalParent.addChildAt(displayObject,originalDepth); 
			}else{
				container.removeChild(displayObject);
			}
		}
		private var addDelay:DelayedCall;
		protected function addDisplayAfterDelay(plugDisplay:IPlugDisplay, depth:int):void{
			if(addDelay){
				addDelay.clear();
				addDelay = null;
			}
			if(!isNaN(_outroBegunAt)){
				var time:Number = (getTimer()/1000);
				var currentPos:Number = time-_outroBegunAt;
				var introPos:Number = (_introOutroOverlap!=1)?(_outroLength*(1-_introOutroOverlap)):0;
				if(currentPos<introPos){
					addDelay = new DelayedCall(addDisplay,introPos-currentPos,true,[plugDisplay.display,depth]);
					addDelay.begin();
					return;
				}
			}
			addDisplay(plugDisplay.display, depth);
		}
		protected function addDisplay(displayObject:DisplayObject, depth:int):void{
			addDelay = null;
			_outroBegunAt = NaN;
			_lastDisplayObject = displayObject;
			if(_lastDisplayObject.parent!=_container){
				if(depth==-1)_container.addChild(_lastDisplayObject);
				else _container.addChildAt(_lastDisplayObject,depth);
			}else if(_container.getChildIndex(_lastDisplayObject)!=depth && depth!=-1){
				_container.setChildIndex(_lastDisplayObject,depth);
			}
		}
		protected function dispatchEventIf(eventType:String, eventClass:Class):void{
			if(hasEventListener(eventType)){
				dispatchEvent(new eventClass(eventType));
			}
		}
		protected function dispatchMeasurementChange():void{
			if(_measurementsChanged)_measurementsChanged.perform(this, _oldMeasX, _oldMeasY, _oldMeasWidth, _oldMeasHeight);
		}
	}
}