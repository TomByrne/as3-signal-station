package org.farmcode.display.containers
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.controls.ScrollBar;
	import org.farmcode.display.controls.TextLabelButton;
	import org.farmcode.display.core.DrawableView;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.core.View;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.grid.RendererGridLayout;
	import org.farmcode.display.scrolling.IScrollable;
	import org.farmcode.display.scrolling.ScrollMetrics;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.instanceFactory.SimpleInstanceFactory;
	
	use namespace DisplayNamespace;
	
	public class AbstractList extends ContainerView implements IScrollable
	{
		DisplayNamespace const ASSUMED_DATA_FIELD:String = "data";
		
		DisplayNamespace function get assumedRendererFactory():SimpleInstanceFactory{
			return _assumedRendererFactory;
		}
		DisplayNamespace function get layout():RendererGridLayout{
			return _layout;
		}
		
		public function get rendererFactory():IInstanceFactory{
			return _rendererFactory;
		}
		public function set rendererFactory(value:IInstanceFactory):void{
			if(_rendererFactory != value){
				_rendererFactory = value;
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
		
		public function get hideScrollBarWhenUnusable():Boolean{
			return _hideScrollBarWhenUnusable;
		}
		public function set hideScrollBarWhenUnusable(value:Boolean):void{
			if(_hideScrollBarWhenUnusable != value){
				_hideScrollBarWhenUnusable = value;
				if(_scrollBar){
					_scrollBar.hideWhenUnusable = _hideScrollBarWhenUnusable;
				}
			}
		}
		
		
		protected var _mouseWheel:Act;
		protected var _scrollMetricsChanged:Act;
		
		protected var _hideScrollBarWhenUnusable:Boolean = true;
		protected var _dataField:String;
		protected var _rendererFactory:IInstanceFactory;
		protected var _scrollBar:ScrollBar;
		protected var _layout:RendererGridLayout;
		protected var _container:IContainerAsset;
		protected var _scrollBarShown:Boolean;
		
		protected var _assumedRendererAsset:IDisplayAsset;
		protected var _assumedAssetFactory:IInstanceFactory;
		protected var _assumedRendererFactory:SimpleInstanceFactory;
		protected var _scrollRect:Rectangle = new Rectangle();
		
		protected var _renderers:Array = [];
		
		public function AbstractList(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			createLayout();
			_layout.measurementsChanged.addHandler(onLayoutMeasChange);
			_layout.scrollMetricsChanged.addHandler(onLayoutScroll);
			_layout.addRendererAct.addHandler(onAddRenderer);
			_layout.removeRendererAct.addHandler(onRemoveRenderer);
		}
		protected function createLayout() : void{
			_layout = new RendererGridLayout(this);
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
		protected function onMouseWheel(from:IInteractiveObjectAsset, actInfo:IMouseActInfo, delta:int) : void{
			if(_mouseWheel)_mouseWheel.perform(this,delta);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_interactiveObjectAsset.mouseWheel.addHandler(onMouseWheel);
			var scrollBarAsset:IDisplayAsset = _containerAsset.takeAssetByName(AssetNames.SCROLL_BAR,IDisplayAsset,true);
			if(scrollBarAsset){
				if(!_scrollBar){
					_scrollBar = new ScrollBar();
					_scrollBar.hideWhenUnusable = _hideScrollBarWhenUnusable;
				}
				_scrollBar.asset = scrollBarAsset;
				_scrollBar.scrollSubject = this;
			}
			_assumedRendererAsset = _containerAsset.takeAssetByName(assumedRendererAssetName(),IDisplayAsset,true);
			if(_assumedRendererAsset){
				_containerAsset.removeAsset(_assumedRendererAsset);
				assessFactory();
			}
			_container = _containerAsset.factory.createContainer();
			_containerAsset.addAsset(_container);
		}
		protected function assumedRendererAssetName() : String{
			return AssetNames.LIST_ITEM;
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_interactiveObjectAsset.mouseWheel.removeHandler(onMouseWheel);
			if(_scrollBar && _scrollBar.asset){
				_containerAsset.returnAsset(_scrollBar.asset);
				_scrollBar.asset = null;
			}
			if(_assumedRendererAsset){
				_containerAsset.addAsset(_assumedRendererAsset);
				_containerAsset.returnAsset(_assumedRendererAsset);
				_assumedRendererAsset = null;
				
				if(_assumedAssetFactory){
					_assumedAssetFactory = null;
				}
				if(_assumedRendererFactory){
					_assumedRendererFactory.instanceProperties = null;
					_assumedRendererFactory = null;
					assessFactory();
				}
			}
			_containerAsset.removeAsset(_container);
			_containerAsset.factory.destroyAsset(_container);
			_container = null;
		}
		protected function onLayoutMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number) : void{
			dispatchMeasurementChange();
		}
		protected function onAddRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			var cast:View = (renderer as View);
			if(cast && !cast.asset){
				checkAssetFactory();
				cast.asset = _assumedAssetFactory.createInstance();
			}
			_renderers.push(renderer.asset);
			if(_container){
				_container.addAsset(renderer.asset);
			}
		}
		protected function onRemoveRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			var index:int = _renderers.indexOf(renderer.asset);
			_renderers.splice(index,1);
			if(_container){
				_container.removeAsset(renderer.asset);
			}
			// TODO: this functionality should really be part of some factory.destory() method or something
			var view:DrawableView = (renderer as DrawableView);
			if(view)view.asset = null;
		}
		override protected function measure() : void{
			assessFactory();
			var layoutMeas:Point = _layout.measurements;
			
			_measurements.x = layoutMeas.x;
			_measurements.y = layoutMeas.y;
			if(_scrollBar){
				var metrics:ScrollMetrics = _scrollBar.scrollSubject.getScrollMetrics(_scrollBar.direction);
				var scrollBar:Boolean = (metrics.maximum>metrics.pageSize && metrics.pageSize) || (!_scrollBar.hideWhenUnusable);
				if(scrollBar){
					var meas:Point = _scrollBar.measurements;
					if(_scrollBar.direction==Direction.VERTICAL){
						_measurements.x += meas.x;
					}else{
						_measurements.y += meas.y;
					}
				}
			}else{
				_measurements.x = layoutMeas.x;
			}
		}
		override protected function draw() : void{
			super.draw();
			drawListAndScrollbar(displayPosition.x,displayPosition.y,displayPosition.width,displayPosition.height);
		}
		protected function drawListAndScrollbar(x:Number, y:Number, width:Number, height:Number) : void{
			var layoutWidth:Number = width;
			var layoutHeight:Number = height;
			if(_scrollBar){
				var meas:Point = _scrollBar.measurements;
				var metrics:ScrollMetrics = _scrollBar.scrollSubject.getScrollMetrics(_scrollBar.direction);
				_scrollBarShown = (metrics.maximum>metrics.pageSize || !_scrollBar.hideWhenUnusable);
				if(_scrollBar.direction==Direction.VERTICAL){
					_scrollBar.setDisplayPosition(width-meas.x-_layout.marginRight,_layout.marginTop,meas.x,height-_layout.marginTop-_layout.marginBottom);
					if(_scrollBarShown){
						layoutWidth = width-meas.x;
					}
				}else{
					_scrollBar.setDisplayPosition(_layout.marginLeft,height-meas.y-_layout.marginBottom,width-_layout.marginLeft-_layout.marginRight,meas.y);
					if(_scrollBarShown){
						layoutHeight = height-meas.y;
					}
				}
			}
			setLayoutDimensions(layoutWidth,layoutHeight);
			_scrollRect.x = _layout.marginLeft;
			_scrollRect.y = _layout.marginTop;
			_scrollRect.width = layoutWidth-_layout.marginLeft-_layout.marginRight;
			_scrollRect.height = height-_layout.marginTop-_layout.marginBottom;
			_container.scrollRect = _scrollRect;
			_container.setPosition(_layout.marginLeft,_layout.marginTop);
		}
		protected function setLayoutDimensions(width:Number, height:Number):void{
			_layout.setDisplayPosition(0,0,width,height);
			if(_layout.flowDirection==Direction.VERTICAL){
				_layout.columnWidths = [width];
				_layout.rowHeights = null;
			}else{
				_layout.columnWidths = null;
				_layout.rowHeights = [height];
			}
		}
		protected function assessFactory():void{
			attemptInit();
			
			var factory:IInstanceFactory;
			var dataField:String;
			if(_rendererFactory){
				factory = _rendererFactory;
				dataField = _dataField || ASSUMED_DATA_FIELD;
			}else if(_assumedRendererAsset){
				if(!_assumedRendererFactory){
					_assumedRendererFactory = createAssumedFactory(_assumedRendererAsset);
				}
				factory = _assumedRendererFactory;
				dataField = ASSUMED_DATA_FIELD;
			}else{
				factory = null;
				dataField = null;
			}
			if(factory!=_layout.rendererFactory || dataField!=_layout.dataField){
				updateFactory(factory,dataField);
			}
		}
		protected function createAssumedFactory(asset:IDisplayAsset):SimpleInstanceFactory{
			var factory:SimpleInstanceFactory = new SimpleInstanceFactory(TextLabelButton);
			factory.useChildFactories = true;
			factory.instanceProperties = new Dictionary();
			factory.instanceProperties["togglable"] = true;
			checkAssetFactory();
			factory.instanceProperties["asset"] = _assumedAssetFactory;
			return factory;
		}
		protected function checkAssetFactory():void{
			if(!_assumedAssetFactory && _assumedRendererAsset){
				_assumedAssetFactory = createAssumedAssetFactory(_assumedRendererAsset);
			}
		}
		protected function createAssumedAssetFactory(asset:IDisplayAsset):IInstanceFactory{
			return asset.getCloneFactory();
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