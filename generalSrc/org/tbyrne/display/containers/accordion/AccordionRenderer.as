package org.tbyrne.display.containers.accordion
{
	import fl.transitions.easing.Regular;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.goasap.events.GoEvent;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.AssetNames;
	import org.tbyrne.display.assets.nativeAssets.actInfo.MouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.controls.ScrollBar;
	import org.tbyrne.display.controls.TextLabel;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.IMinimisableLayoutSubject;
	import org.tbyrne.display.validation.ValidationFlag;
	import org.tbyrne.tweening.LooseTween;
	
	use namespace DisplayNamespace;
	
	public class AccordionRenderer extends LayoutView implements IAccordionRenderer
	{
		
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
				invalidateMeasurements();
				invalidateSize();
			}
		}
		
		/*public function get label():String{
			return _label.data.label;
		}
		public function set label(value:IString):void{
			_label.data = value;
		}*/
		
		public function get data():IControlData{
			return _data;
		}
		public function set data(value:IControlData):void{
			if(_data != value){
				if(_booleanProvider){
					_booleanProvider.booleanValueChanged.removeHandler(onOpenChanged);
				}
				_openFract = NaN;
				_data = value;
				_label.data = value;
				if(_data){
					_booleanProvider = _data.selected;
					if(_booleanProvider){
						_booleanConsumer = (_booleanProvider as IBooleanConsumer);
						_booleanProvider.booleanValueChanged.addHandler(onOpenChanged);
						booleanValue = _booleanProvider.booleanValue;
						if(_booleanConsumer)commitProviderState();
					}else{
						_booleanConsumer = null;
						booleanValue = false;
					}
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
		
		protected var _data:IControlData;
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
		
		protected var _labelMeas:Point;
		
		protected var _openState:StateDef = new StateDef([STATE_OPEN,STATE_CLOSED],0);
		
		public function AccordionRenderer(asset:IDisplayObject=null){
			_label = new TextLabel();
			super(asset);
			_label.measurementsChanged.addHandler(onMeasChange);
			_labelMeas = _label.measurements || new Point();
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
			if(_containerAsset.containsAssetByName(AssetNames.LABEL_FIELD)){
				_label.asset = _asset;
			}
			_interactiveObjectAsset.clicked.addHandler(onAssetClick);
			
			var scrollBarAsset:IDisplayObject = _containerAsset.takeAssetByName(AssetNames.SCROLL_BAR,true);
			if(scrollBarAsset){
				if(!_scrollBar){
					_scrollBar = new ScrollBar();
				}
				_scrollBar.asset = scrollBarAsset;
			}
		}
		override protected function unbindFromAsset() : void{
			_label.asset = null;
			_interactiveObjectAsset.clicked.removeHandler(onAssetClick);
			
			if(_scrollBar){
				_scrollBar.asset = null;
			}
		}
		protected function onAssetClick(from:IInteractiveObject, mouseInfo:MouseActInfo) : void{
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
			invalidatePos();
		}
		override protected function measure():void{
			var minMeas:Point = minMeasurements;
			_measurements.x = minMeas.x;
			_measurements.y = minMeas.y;
			var childMeasurements:Rectangle = getContainerMeasurements();
			if(childMeasurements){
				switch(_labelPosition){
					case Anchor.TOP:
					case Anchor.TOP_LEFT:
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM:
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM_RIGHT:
						_measurements.y += childMeasurements.height;
						break;
				}
				switch(_labelPosition){
					case Anchor.LEFT:
					case Anchor.TOP_LEFT:
					case Anchor.BOTTOM_LEFT:
					case Anchor.RIGHT:
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM_RIGHT:
						_measurements.x += childMeasurements.width;
						break;
				}
			}
		}
		override protected function commitPosition():void{
			measurements;// this will force measuring if it's invalid
			var lackX:Number = (_measurements.x<_openWidth?_openWidth-_measurements.x:0);
			var lackY:Number = (_measurements.y<_openHeight?_openHeight-_measurements.y:0);
			
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
				_label.setPosition(position.x+labelX,position.y+labelY);
				_label.setSize(labelW,labelH);
			}else{
				asset.setPosition(position.x+labelX,position.y+labelY);
			}
			if(_scrollBar){
				if(_scrollBar.hideWhenUnusable)setContainerSize(childX,childY,childW,childH);
				if(_scrollBar.isUsable || !_scrollBar.hideWhenUnusable){
					_scrollBar.direction = scrollDir;
					var vert:Boolean = (scrollDir==Direction.VERTICAL);
					var scrollMeas:Point = _scrollBar.measurements;
					var scrollX:Number;
					var scrollY:Number;
					var scrollW:Number;
					var scrollH:Number;
					if(vert){
						scrollX = _openWidth-scrollMeas.x;
						scrollY = childY;
						scrollW = scrollMeas.x;
						scrollH = _openHeight-childY;
						childW -= scrollMeas.x;
					}else{
						scrollX = childX;
						scrollY = _openHeight-scrollMeas.y;
						scrollW = _openWidth-childX;
						scrollH = scrollMeas.y;
						childH -= scrollMeas.y;
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
			_scrollBar.setPosition(x,y);
			_scrollBar.setSize(width,height);
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
		protected function onMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			_labelMeas = _label.measurements || new Point();
			_minMeasurementsFlag.invalidate();
			if(_minMeasurementsChanged)_minMeasurementsChanged.perform(this);
			invalidateMeasurements();
		}
		protected function checkMinMeas():void{
			_minMeasurements.x = _labelMeas.x;
			_minMeasurements.y = _labelMeas.y;
		}
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_openState);
			return fill;
		}
	}
}