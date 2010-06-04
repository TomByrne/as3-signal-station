package org.farmcode.display.behaviour.containers
{
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.behaviour.IViewBehaviour;
	import org.farmcode.display.behaviour.controls.ScrollBar;
	import org.farmcode.display.behaviour.controls.TextLabelButton;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.grid.RendererGridLayout;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.instanceFactory.SimpleInstanceFactory;
	
	public class AbstractList extends ContainerView implements IScrollable
	{
		public function get rendererFactory():IInstanceFactory{
			return _rendererFactory;
		}
		public function set rendererFactory(value:IInstanceFactory):void{
			if(_rendererFactory != value){
				_rendererFactory = value;
				assessFactory();
			}
		}
		
		public function get dataField():String{
			return _dataField;
		}
		public function set dataField(value:String):void{
			if(_dataField != value){
				_dataField = value;
				assessFactory();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scrollMetricsChanged():IAct{
			if(!_scrollMetricsChanged)_scrollMetricsChanged = new Act();
			return _scrollMetricsChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseWheel():IAct{
			if(!_mouseWheel)_mouseWheel = new Act();
			return _mouseWheel;
		}
		
		
		protected var _mouseWheel:Act;
		protected var _scrollMetricsChanged:Act;
		
		protected var _dataField:String;
		protected var _rendererFactory:IInstanceFactory;
		protected var _scrollBar:ScrollBar;
		protected var _layout:RendererGridLayout;
		protected var _container:DisplayObjectContainer;
		protected var _scrollBarShown:Boolean;
		
		protected var _assumedRendererAsset:DisplayObject;
		protected var _assumedRendererFactory:SimpleInstanceFactory;
		protected var _scrollRect:Rectangle = new Rectangle();
		
		public function AbstractList(asset:DisplayObject=null){
			super(asset);
			_layout = new RendererGridLayout();
			_layout.measurementsChanged.addHandler(onLayoutMeasChange);
			_layout.scrollMetricsChanged.addHandler(onLayoutScroll);
			_layout.addRendererAct.addHandler(onAddRenderer);
			_layout.removeRendererAct.addHandler(onRemoveRenderer);
			_displayMeasurements = new Rectangle();
			_container = new Sprite();
		}
		protected function onLayoutScroll(from:RendererGridLayout, direction:String, metrics:ScrollMetrics) : void{
			if(_scrollBar && _scrollBar.direction==direction){
				var metrics:ScrollMetrics = _scrollBar.scrollSubject.getScrollMetrics(_scrollBar.direction);
				var scrollBar:Boolean = (metrics.maximum>metrics.pageSize);
				if(scrollBar!=_scrollBarShown){
					dispatchMeasurementChange();
					invalidate();
				}
			}
			if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this,direction,metrics);
		}
		protected function onMouseWheel(e:MouseEvent) : void{
			if(_mouseWheel)_mouseWheel.perform(this,e.delta);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			asset.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			var scrollBarAsset:DisplayObject = containerAsset.getChildByName("scrollBar");
			if(scrollBarAsset){
				if(!_scrollBar){
					_scrollBar = new ScrollBar();
				}
				_scrollBar.asset = scrollBarAsset;
				_scrollBar.scrollSubject = this;
			}
			_assumedRendererAsset = containerAsset.getChildByName(assumedRendererAssetName());
			if(_assumedRendererAsset){
				containerAsset.removeChild(_assumedRendererAsset);
				assessFactory();
			}
			containerAsset.addChild(_container);
		}
		protected function assumedRendererAssetName() : String{
			return "listItem";
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			asset.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			if(_scrollBar){
				_scrollBar.asset = null;
			}
			if(_assumedRendererAsset){
				containerAsset.addChild(_assumedRendererAsset);
				_assumedRendererAsset = null;
				if(_assumedRendererFactory){
					_assumedRendererFactory.instanceProperties = null;
					_assumedRendererFactory = null;
					assessFactory();
				}
			}
			containerAsset.removeChild(_container);
		}
		protected function onLayoutMeasChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number) : void{
			dispatchMeasurementChange();
		}
		protected function onAddRenderer(layout:RendererGridLayout, renderer:IViewBehaviour) : void{
			_container.addChild(renderer.asset);
		}
		protected function onRemoveRenderer(layout:RendererGridLayout, renderer:IViewBehaviour) : void{
			_container.removeChild(renderer.asset);
		}
		override protected function measure() : void{
			assessFactory();
			_displayMeasurements.x = _layout.displayMeasurements.x;
			_displayMeasurements.y = _layout.displayMeasurements.y;
			_displayMeasurements.height = _layout.displayMeasurements.height;
			if(_scrollBar){
				var metrics:ScrollMetrics = _scrollBar.scrollSubject.getScrollMetrics(_scrollBar.direction);
				var scrollBar:Boolean = (metrics.maximum>metrics.pageSize && metrics.pageSize) || (!_scrollBar.hideWhenUnusable);
				if(scrollBar){
					var meas:Rectangle = _scrollBar.displayMeasurements;
					_displayMeasurements.width = _layout.displayMeasurements.width+meas.width;
				}else{
					_displayMeasurements.width = _layout.displayMeasurements.width;
				}
			}else{
				_displayMeasurements.width = _layout.displayMeasurements.width;
			}
		}
		override protected function draw() : void{
			super.draw();
			drawListAndScrollbar(displayPosition);
		}
		protected function drawListAndScrollbar(position:Rectangle) : void{
			var layoutWidth:Number = position.width;
			var layoutHeight:Number = position.height;
			if(_scrollBar){
				var meas:Rectangle = _scrollBar.displayMeasurements;
				var metrics:ScrollMetrics = _scrollBar.scrollSubject.getScrollMetrics(_scrollBar.direction);
				_scrollBarShown = (metrics.maximum>metrics.pageSize);
				if(_scrollBar.direction==Direction.VERTICAL || !_scrollBar.hideWhenUnusable){
					_scrollBar.setDisplayPosition(position.width-meas.width,0,meas.width,position.height);
					if(metrics.maximum>metrics.pageSize){
						layoutWidth = position.width-meas.width;
					}
				}else{
					_scrollBar.setDisplayPosition(0,position.height-meas.height,position.width,meas.height);
					if(metrics.maximum>metrics.pageSize || !_scrollBar.hideWhenUnusable){
						layoutHeight = position.height-meas.height;
					}
				}
			}else{
				layoutWidth = position.width;
			}
			_layout.columnWidths = [layoutWidth];
			_layout.setDisplayPosition(0,0,layoutWidth,layoutHeight);
			_scrollRect.width = layoutWidth;
			_scrollRect.height = position.height;
			_container.scrollRect = _scrollRect;
		}
		protected function assessFactory():void{
			var factory:IInstanceFactory;
			var dataField:String;
			if(_rendererFactory){
				factory = _rendererFactory;
				dataField = _dataField;
			}else if(_assumedRendererAsset){
				if(!_assumedRendererFactory){
					_assumedRendererFactory = new SimpleInstanceFactory(TextLabelButton);
					_assumedRendererFactory.useChildFactories = true;
					_assumedRendererFactory.instanceProperties = new Dictionary();
					_assumedRendererFactory.instanceProperties["asset"] = new SimpleInstanceFactory(_assumedRendererAsset["constructor"]);
				}
				factory = _assumedRendererFactory;
				dataField = "data";
			}else{
				factory = null;
				dataField = null;
			}
			if(factory!=_layout.rendererFactory || dataField!=_layout.dataField){
				updateFactory(factory,dataField);
			}
		}
		protected function updateFactory(factory:IInstanceFactory, dataField:String):void{
			_layout.rendererFactory = factory;
			_layout.dataField = dataField;
		}
		public function addScrollWheelListener(direction:String):Boolean{
			return true;
		}
		public function getScrollMetrics(direction:String):ScrollMetrics{
			return _layout.getScrollMetrics(direction);
		}
		public function setScrollMetrics(direction:String,metrics:ScrollMetrics):void{
			_layout.setScrollMetrics(direction,metrics);
		}
		public function getScrollMultiplier(direction:String):Number{
			if((direction==Direction.VERTICAL && _layout.verticalScrollByLine) || 
				(direction==Direction.HORIZONTAL && _layout.horizontalScrollByLine)){
				return 1;
			}else{
				return 10;
			}
		}
	}
}