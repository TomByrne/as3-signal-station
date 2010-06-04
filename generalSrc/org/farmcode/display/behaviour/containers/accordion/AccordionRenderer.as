package org.farmcode.display.behaviour.containers.accordion
{
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import fl.transitions.easing.Regular;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.flags.ValidationFlag;
	import org.farmcode.display.behaviour.LayoutViewBehaviour;
	import org.farmcode.display.behaviour.controls.ScrollBar;
	import org.farmcode.display.behaviour.controls.TextLabel;
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.goasap.events.GoEvent;
	
	public class AccordionRenderer extends LayoutViewBehaviour implements IAccordionRenderer
	{
		public function get minimumSize():Rectangle{
			return _label.displayMeasurements;
		}
		public function get maximumSize():Rectangle{
			_maximumSizeFlag.validate();
			return _label.displayMeasurements;
		}
		public function set accordionIndex(value:int):void{
			
		}
		
		public function get open():Boolean{
			return _open;
		}
		public function set open(value:Boolean):void{
			if(_open!=value){
				_open = value;
				var destFract:Number = (value?1:0);
				var trans:Boolean;
				if(!isNaN(_openFract)){
					if(!value && closeEasing!=null && !isNaN(closeDuration)){
						trans = true;
						doTransition(destFract, closeEasing, closeDuration, true);
					}else if(openEasing!=null && !isNaN(openDuration)){
						trans = true;
						doTransition(destFract, openEasing, openDuration, !value);
					}
				}
				if(!trans){
					_openFract = destFract;
					dispatchMeasurementChange();
				}
			}else if(isNaN(_openFract)){
				_openFract = (value?1:0);
			}
		}
		override public function set asset(value:DisplayObject):void{
			super.asset = value;
			_label.asset = value;
			
		}
		
		public function get labelPosition():String{
			return _labelPosition;
		}
		public function set labelPosition(value:String):void{
			if(_labelPosition!=value){
				_labelPosition = value;
				_maximumSizeFlag.invalidate();
				invalidate();
			}
		}
		
		public function get label():String{
			return _label.data;
		}
		public function set label(value:String):void{
			_label.data = value;
		}
		
		public function get data():IStringProvider{
			return _label.data;
		}
		public function set data(value:IStringProvider):void{
			_label.data = value;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get select():IAct{
			if(!_select)_select = new Act();
			return _select;
		}
		
		protected var _select:Act;
		
		public var openEasing:Function = Regular.easeInOut;
		public var openDuration:Number = 0.2;
		
		public var closeEasing:Function;
		public var closeDuration:Number;
		
		private var _data:IStringProvider;
		private var _labelPosition:String = Anchor.TOP;
		private var _open:Boolean;
		private var _openFract:Number;
		private var _minimumSize:Rectangle;
		private var _maximumSize:Rectangle;
		private var _openSize:Rectangle;
		protected var _maximumSizeFlag:ValidationFlag;
		
		protected var _label:TextLabel;
		protected var _scrollBar:ScrollBar;
		
		public function AccordionRenderer(asset:DisplayObject=null){
			_label = new TextLabel();
			super(asset);
			_displayMeasurements = new Rectangle();
			_maximumSize = new Rectangle();
			_minimumSize = new Rectangle();
			_openSize = new Rectangle();
			_label.measurementsChanged.addHandler(onMeasChange);
			_maximumSizeFlag = new ValidationFlag(validateMaxSize,false);
		}
		public function setOpenSize(x:Number, y:Number, width:Number, height:Number):void{
			_openSize.x = x;
			_openSize.y = y;
			_openSize.width = width;
			_openSize.height = height;
			dispatchMeasurementChange();
		}
		override protected function bindToAsset() : void{
			asset.addEventListener(MouseEvent.CLICK, onAssetClick);
			
			var scrollBarAsset:DisplayObject = containerAsset.getChildByName("scrollBar");
			if(scrollBarAsset){
				_scrollBar = new ScrollBar(scrollBarAsset);
			}
		}
		override protected function unbindFromAsset() : void{
			asset.removeEventListener(MouseEvent.CLICK, onAssetClick);
			
			if(_scrollBar){
				_scrollBar = null;
			}
		}
		protected function onAssetClick(e:Event) : void{
			if(_select)_select.perform(this);
		}
		override protected function draw() : void{
			var labelMeasurements:Rectangle = _label.displayMeasurements;
			var labelX:Number;
			var labelY:Number;
			var labelW:Number;
			var labelH:Number;
			var childX:Number;
			var childY:Number;
			var childW:Number;
			var childH:Number;
			var scrollDir:String = Direction.VERTICAL;
			switch(_labelPosition){
				case Anchor.TOP:
				case Anchor.TOP_LEFT:
				case Anchor.TOP_RIGHT:
					labelY = 0;
					labelH = labelMeasurements.height;
					childY = labelH;
					childH = _openSize.height-labelMeasurements.height;
					break;
				case Anchor.BOTTOM:
				case Anchor.BOTTOM_LEFT:
				case Anchor.BOTTOM_RIGHT:
					labelY = _openSize.height-labelMeasurements.height;
					labelH = labelMeasurements.height;
					childY = 0;
					childH = labelY;
					break;
				default:
					scrollDir = Direction.HORIZONTAL;
					labelY = 0;
					childY = 0;
					childH = labelH = _openSize.height;
					break;
				
			}
			switch(_labelPosition){
				case Anchor.LEFT:
				case Anchor.TOP_LEFT:
				case Anchor.BOTTOM_LEFT:
					labelX = 0;
					labelW = labelMeasurements.width;
					childX = labelW;
					childW = _openSize.width-labelMeasurements.width;
					break;
				case Anchor.RIGHT:
				case Anchor.TOP_RIGHT:
				case Anchor.BOTTOM_RIGHT:
					labelX = _openSize.width-labelMeasurements.width;
					labelW = labelMeasurements.width;
					childX = 0;
					childW = labelX;
					break;
				default:
					labelX = 0;
					childX = 0;
					childW = labelW = _openSize.width;
					break;
			}
			_label.setDisplayPosition(displayPosition.x+labelX,displayPosition.y+labelY,labelW,labelH);
			if(_scrollBar){
				if(_scrollBar.hideWhenUnusable)setContainerSize(childX,childY,childW,childH);
				if(_scrollBar.isUsable || !_scrollBar.hideWhenUnusable){
					_scrollBar.direction = scrollDir;
					var vert:Boolean = (scrollDir==Direction.VERTICAL);
					var scrollMeas:Rectangle = _scrollBar.displayMeasurements;
					var scrollX:Number;
					var scrollY:Number;
					var scrollW:Number;
					var scrollH:Number;
					if(vert){
						scrollX = _openSize.width-scrollMeas.width;
						scrollY = childY;
						scrollW = scrollMeas.width;
						scrollH = _openSize.height-childY;
						childW -= scrollMeas.width;
					}else{
						scrollX = childX;
						scrollY = _openSize.height-scrollMeas.height;
						scrollW = _openSize.width-childX;
						scrollH = scrollMeas.height;
						childH -= scrollMeas.height;
					}
					setContainerSize(childX,childY,childW,childH);
					setScrollBarSize(scrollX,scrollY,scrollW,scrollH);
				}
			}else{
				setContainerSize(childX,childY,childW,childH);
			}
		}
		protected function getContainerMeasurements() : Rectangle{
			// override me
			return null;
		}
		protected function setContainerSize(x:Number, y:Number, width:Number, height:Number) : void{
			// override me
		}
		protected function setScrollBarSize(x:Number, y:Number, width:Number, height:Number) : void{
			_scrollBar.setDisplayPosition(x,y,width,height);
		}
		protected function validateMaxSize():void{
			var labelMeasurements:Rectangle = _label.displayMeasurements;
			_maximumSize.x = labelMeasurements.x;
			_maximumSize.y = labelMeasurements.y;
			_maximumSize.width = labelMeasurements.width;
			_maximumSize.height = labelMeasurements.height;
			var childMeasurements:Rectangle = getContainerMeasurements();
			if(childMeasurements){
				switch(_labelPosition){
					case Anchor.TOP:
					case Anchor.TOP_LEFT:
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM:
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM_RIGHT:
						_maximumSize.height += childMeasurements.height;
						break;
				}
				switch(_labelPosition){
					case Anchor.LEFT:
					case Anchor.TOP_LEFT:
					case Anchor.BOTTOM_LEFT:
					case Anchor.RIGHT:
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM_RIGHT:
						_maximumSize.width += childMeasurements.width;
						break;
				}
			}
		}
		override protected function measure():void{
			var scaleH:Boolean;
			switch(_labelPosition){
				case Anchor.TOP:
				case Anchor.TOP_LEFT:
				case Anchor.TOP_RIGHT:
				case Anchor.BOTTOM:
				case Anchor.BOTTOM_LEFT:
				case Anchor.BOTTOM_RIGHT:
					scaleH = true;
					break;
			}
			var scaleW:Boolean;
			switch(_labelPosition){
				case Anchor.LEFT:
				case Anchor.TOP_LEFT:
				case Anchor.BOTTOM_LEFT:
				case Anchor.RIGHT:
				case Anchor.TOP_RIGHT:
				case Anchor.BOTTOM_RIGHT:
					scaleW = true;
					break;
			}
			
			var labelMeasurements:Rectangle = _label.displayMeasurements;
			var width:Number;
			if(scaleW){
				width = labelMeasurements.width+((_openSize.width-labelMeasurements.width)*_openFract);
			}else{
				width = _openSize.width;
			}
			var height:Number;
			if(scaleH){
				height = labelMeasurements.height+((_openSize.height-labelMeasurements.height)*_openFract);
			}else{
				height = _openSize.height;
			}
			if(_displayMeasurements.width != width || _displayMeasurements.height != height){
				_displayMeasurements.width = width;
				_displayMeasurements.height = height;
				invalidate();
			}
		}
		protected function doTransition(destFract:Number, easing:Function, duration:Number, invertEasing:Boolean):void{
			var start:Number;
			var end:Number;
			var listener:Function;
			if(!invertEasing){
				start = _openFract;
				end = destFract;
				listener = onTransUpdate;
			}else{
				start = (1-_openFract);
				end = (1-destFract);
				listener = onTransInvUpdate;
			}
			var target:Object = {value:start};
			var tween:LooseTween = new LooseTween(target,{value:end},easing,duration);
			tween.addEventListener(GoEvent.UPDATE, listener);
			tween.start();
		}
		protected function onTransUpdate(e:GoEvent):void{
			var target:Object = (e.target as LooseTween).target;
			_openFract = target.value;
			dispatchMeasurementChange();
		}
		protected function onTransInvUpdate(e:GoEvent):void{
			var target:Object = (e.target as LooseTween).target;
			_openFract = 1-target.value;
			dispatchMeasurementChange();
		}
		protected function onMeasChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
	}
}