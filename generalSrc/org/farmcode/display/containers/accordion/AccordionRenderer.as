package org.farmcode.display.containers.accordion
{
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import fl.transitions.easing.Regular;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.nativeAssets.actInfo.MouseActInfo;
	import org.farmcode.display.assets.states.StateDef;
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.controls.ScrollBar;
	import org.farmcode.display.controls.TextLabel;
	import org.farmcode.display.core.LayoutView;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.IMinimisableLayoutSubject;
	import org.farmcode.display.validation.ValidationFlag;
	import org.goasap.events.GoEvent;
	
	use namespace DisplayNamespace;
	
	public class AccordionRenderer extends LayoutView implements IAccordionRenderer
	{
		DisplayNamespace static const SCROLL_BAR:String = "scrollBar";
		
		// States
		DisplayNamespace static const STATE_OPEN:String = "open";
		DisplayNamespace static const STATE_CLOSED:String = "closed";
		
		
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			if(!_booleanValueChanged)_booleanValueChanged = new Act();
			return _booleanValueChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get minMeasurementsChanged():IAct{
			if(!_minMeasurementsChanged)_minMeasurementsChanged = new Act();
			return _minMeasurementsChanged;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get userChangedOpen():IAct{
			if(!_userChangedOpen)_userChangedOpen = new Act();
			return _userChangedOpen;
		}
		
		
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get openFractChanged():IAct{
			if(!_openFractChanged)_openFractChanged = new Act();
			return _openFractChanged;
		}
		
		
		public function get minMeasurements():Point{
			_minMeasurementsFlag.validate();
			return _minMeasurements;
		}
		
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(_booleanValue!=value || isNaN(_openFract)){
				_booleanValue = value;
				_openState.selection = _booleanValue?0:1;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
				if(_booleanConsumer){
					_booleanConsumer.booleanValue = value;
				}else{
					commitProviderState();
				}
			}
		}
		
		public function get labelPosition():String{
			return _labelPosition;
		}
		public function set labelPosition(value:String):void{
			if(_labelPosition!=value){
				_labelPosition = value;
				dispatchMeasurementChange();
				invalidate();
			}
		}
		
		public function get label():String{
			return _label.data;
		}
		public function set label(value:String):void{
			_label.data = value;
		}
		
		public function get data():IBooleanProvider{
			return _booleanProvider;
		}
		public function set data(value:IBooleanProvider):void{
			if(_booleanProvider != value){
				if(_booleanProvider){
					_booleanProvider.booleanValueChanged.removeHandler(onOpenChanged);
				}
				_openFract = NaN;
				_booleanProvider = value;
				_label.data = value;
				if(_booleanProvider){
					_booleanConsumer = (value as IBooleanConsumer);
					_booleanProvider.booleanValueChanged.addHandler(onOpenChanged);
					booleanValue = value.booleanValue;
					if(_booleanConsumer)commitProviderState();
				}else{
					_booleanConsumer = null;
					booleanValue = false;
				}
			}
		}
		public function get openFract():Number{
			return _openFract;
		}
		
		protected var _minMeasurementsChanged:Act;
		protected var _booleanValueChanged:Act;
		protected var _openFractChanged:Act;
		protected var _userChangedOpen:Act;
		
		protected var _booleanProvider:IBooleanProvider;
		protected var _booleanConsumer:IBooleanConsumer;
		
		public var openEasing:Function = Regular.easeOut;
		public var openDuration:Number = 0.2;
		
		public var closeEasing:Function;
		public var closeDuration:Number;
		
		protected var _minMeasurementsFlag:ValidationFlag = new ValidationFlag(checkMinMeas,false);
		protected var _minMeasurements:Point = new Point();
		protected var _labelPosition:String = Anchor.TOP;
		private var _openFract:Number;
		private var _booleanValue:Boolean;
		
		protected var _label:TextLabel;
		protected var _scrollBar:ScrollBar;
		
		protected var _openWidth:Number;
		protected var _openHeight:Number;
		
		protected var _labelMeas:Rectangle;
		
		protected var _openState:StateDef = new StateDef([STATE_OPEN,STATE_CLOSED],0);
		
		public function AccordionRenderer(asset:IDisplayAsset=null){
			_label = new TextLabel();
			super(asset);
			_displayMeasurements = new Rectangle();
			_label.measurementsChanged.addHandler(onMeasChange);
			_labelMeas = _label.displayMeasurements || new Rectangle();
			booleanValue = false;
		}
		public function onOpenChanged(from:IBooleanProvider):void{
			booleanValue = from.booleanValue;
			if(_booleanConsumer)commitProviderState();
		}
		public function commitProviderState():void{
			var destFract:Number = (_booleanValue?1:0);
			var trans:Boolean;
			if(!isNaN(_openFract)){
				if(!_booleanValue && closeEasing!=null && !isNaN(closeDuration)){
					trans = true;
					doTransition(destFract, closeEasing, closeDuration, true);
				}else if(openEasing!=null && !isNaN(openDuration)){
					trans = true;
					doTransition(destFract, openEasing, openDuration, !_booleanValue);
				}
			}
			if(!trans){
				_openFract = destFract;
				if(_openFractChanged)_openFractChanged.perform(this);
			}
		}
		public function setOpen(value:Boolean):void{
			booleanValue = value;
		}
		override protected function bindToAsset() : void{
			if(_containerAsset.containsAssetByName(TextLabel.LABEL_FIELD_CHILD)){
				_label.asset = _asset;
			}
			_interactiveObjectAsset.click.addHandler(onAssetClick);
			
			var scrollBarAsset:IDisplayAsset = _containerAsset.takeAssetByName(SCROLL_BAR,IDisplayAsset,true);
			if(scrollBarAsset){
				if(!_scrollBar){
					_scrollBar = new ScrollBar();
				}
				_scrollBar.asset = scrollBarAsset;
			}
		}
		override protected function unbindFromAsset() : void{
			_label.asset = null;
			_interactiveObjectAsset.click.removeHandler(onAssetClick);
			
			if(_scrollBar){
				_scrollBar.asset = null;
			}
		}
		protected function onAssetClick(from:IInteractiveObjectAsset, mouseInfo:MouseActInfo) : void{
			// this allows data providers to ignore calls
			var boolWas:Boolean = _booleanValue;
			if(_booleanConsumer)_booleanConsumer.booleanValue = !booleanValue;
			else booleanValue = !booleanValue;
			if(boolWas!=_booleanValue && _userChangedOpen){
				_userChangedOpen.perform(this);
			}
		}
		public function setOpenArea(width:Number, height:Number):void{
			_openWidth = width;
			_openHeight = height;
			invalidate();
		}
		override protected function measure():void{
			var minMeas:Point = minMeasurements;
			_displayMeasurements.width = minMeas.x;
			_displayMeasurements.height = minMeas.y;
			var childMeasurements:Rectangle = getContainerMeasurements();
			if(childMeasurements){
				switch(_labelPosition){
					case Anchor.TOP:
					case Anchor.TOP_LEFT:
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM:
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM_RIGHT:
						_displayMeasurements.height += childMeasurements.height;
						break;
				}
				switch(_labelPosition){
					case Anchor.LEFT:
					case Anchor.TOP_LEFT:
					case Anchor.BOTTOM_LEFT:
					case Anchor.RIGHT:
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM_RIGHT:
						_displayMeasurements.width += childMeasurements.width;
						break;
				}
			}
		}
		override protected function draw() : void{
			_measureFlag.validate();
			var lackX:Number = (_displayMeasurements.width<_openWidth?_openWidth-_displayMeasurements.width:0);
			var lackY:Number = (_displayMeasurements.height<_openHeight?_openHeight-_displayMeasurements.height:0);
			
			var labelX:Number;
			var labelY:Number;
			var labelW:Number;
			var labelH:Number;
			var childX:Number;
			var childY:Number;
			var childW:Number;
			var childH:Number;
			var scrollDir:String = Direction.VERTICAL;
			var minMeas:Point = minMeasurements;
			switch(_labelPosition){
				case Anchor.TOP:
				case Anchor.TOP_LEFT:
				case Anchor.TOP_RIGHT:
					labelY = 0;
					labelH = minMeas.y+lackY;
					childY = labelH;
					childH = _openHeight-minMeas.y;
					break;
				case Anchor.BOTTOM:
				case Anchor.BOTTOM_LEFT:
				case Anchor.BOTTOM_RIGHT:
					labelY = _openHeight-minMeas.y;
					labelH = minMeas.y+lackY;
					childY = 0;
					childH = labelY;
					break;
				default:
					scrollDir = Direction.HORIZONTAL;
					labelY = 0;
					childY = 0;
					childH = labelH = _openHeight;
					break;
				
			}
			switch(_labelPosition){
				case Anchor.LEFT:
				case Anchor.TOP_LEFT:
				case Anchor.BOTTOM_LEFT:
					labelX = 0;
					labelW = minMeas.x+lackX;
					childX = labelW;
					childW = _openWidth-minMeas.x;
					break;
				case Anchor.RIGHT:
				case Anchor.TOP_RIGHT:
				case Anchor.BOTTOM_RIGHT:
					labelX = _openWidth-minMeas.x;
					labelW = minMeas.x+lackX;
					childX = 0;
					childW = labelX;
					break;
				default:
					labelX = 0;
					childX = 0;
					childW = labelW = _openWidth;
					break;
			}
			if(_label.asset){
				_label.setDisplayPosition(displayPosition.x+labelX,displayPosition.y+labelY,labelW,labelH);
			}else{
				asset.x = displayPosition.x+labelX;
				asset.y = displayPosition.y+labelY;
			}
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
						scrollX = _openWidth-scrollMeas.width;
						scrollY = childY;
						scrollW = scrollMeas.width;
						scrollH = _openHeight-childY;
						childW -= scrollMeas.width;
					}else{
						scrollX = childX;
						scrollY = _openHeight-scrollMeas.height;
						scrollW = _openWidth-childX;
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
			if(_openFractChanged)_openFractChanged.perform(this);
		}
		protected function onTransInvUpdate(e:GoEvent):void{
			var target:Object = (e.target as LooseTween).target;
			_openFract = 1-target.value;
			if(_openFractChanged)_openFractChanged.perform(this);
		}
		protected function onMeasChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			_labelMeas = _label.displayMeasurements || new Rectangle();
			_minMeasurementsFlag.invalidate();
			if(_minMeasurementsChanged)_minMeasurementsChanged.perform(this);
			dispatchMeasurementChange();
		}
		protected function checkMinMeas():void{
			_minMeasurements.x = _labelMeas.width;
			_minMeasurements.y = _labelMeas.height;
		}
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_openState);
			return fill;
		}
	}
}