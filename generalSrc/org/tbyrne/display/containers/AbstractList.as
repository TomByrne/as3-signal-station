package org.tbyrne.display.containers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.AssetNames;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.controls.ListRenderer;
	import org.tbyrne.display.controls.ScrollBar;
	import org.tbyrne.display.core.DrawableView;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.grid.RendererGridLayout;
	import org.tbyrne.display.scrolling.IScrollMetrics;
	import org.tbyrne.display.scrolling.IScrollable;
	import org.tbyrne.display.scrolling.MouseDragScroller;
	import org.tbyrne.display.scrolling.MouseWheelScroller;
	import org.tbyrne.display.scrolling.ScrollMultiplier;
	import org.tbyrne.factories.IInstanceFactory;
	import org.tbyrne.factories.InstanceFactory;
	import org.tbyrne.factories.ProxyInstanceFactory;
	
	use namespace DisplayNamespace;
	
	public class AbstractList extends ContainerView implements IScrollable
	{
		DisplayNamespace const ASSUMED_DATA_FIELD:String = "data";
		
		DisplayNamespace function get assumedRendererFactory():InstanceFactory{
			if(isBound)assessFactory();
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
				if(_assumedAssetProxyFactory){
					_assumedAssetProxyFactory.nestedFactory = _rendererFactory;
				}
				if(isBound)assessFactory();
			}
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
		
		
		public function get alwaysUseScrollRect():Boolean{
			return _alwaysUseScrollRect;
		}
		public function set alwaysUseScrollRect(value:Boolean):void{
			if(_alwaysUseScrollRect!=value){
				_alwaysUseScrollRect = value;
				if(isBound)commitScrollRect();
			}
		}
		
		private var _alwaysUseScrollRect:Boolean = false;
		
		protected var _hideScrollBarWhenUnusable:Boolean = true;
		protected var _dataField:String;
		protected var _rendererFactory:IInstanceFactory;
		protected var _scrollBar:ScrollBar;
		protected var _layout:RendererGridLayout;
		
		protected var _vScrollMetrics:IScrollMetrics;
		protected var _hScrollMetrics:IScrollMetrics;
		protected var _vPixScrollMetrics:IScrollMetrics;
		protected var _hPixScrollMetrics:IScrollMetrics;
		
		protected var _container:IDisplayObjectContainer;
		protected var _scrollBarShown:Boolean;
		
		protected var _assumedRendererAsset:IDisplayObject;
		protected var _assumedAssetFactory:IInstanceFactory;
		protected var _assumedRendererFactory:InstanceFactory;
		protected var _scrollRect:Rectangle = new Rectangle();
		protected var _scrollMetrics:IScrollMetrics;
		protected var _mouseWheelScroller:MouseWheelScroller;
		protected var _mouseDragScroller:MouseDragScroller;
		
		//protected var _factoryAssumedAssetSet:Boolean;
		//protected var _factoryAssumedAssetProps:Dictionary;
		protected var _assumedAssetProxyFactory:ProxyInstanceFactory;
		
		protected var _renderers:Array = [];
		
		public function AbstractList(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			createLayout();
			_layout.scrollRectMode = true;
			
			_vScrollMetrics = _layout.getScrollMetrics(Direction.VERTICAL);
			_vPixScrollMetrics = _layout.getPixScrollMetrics(Direction.VERTICAL);
			_vPixScrollMetrics.scrollMetricsChanged.addHandler(onScrollChange);
			
			_hScrollMetrics = _layout.getScrollMetrics(Direction.HORIZONTAL);
			_hPixScrollMetrics = _layout.getPixScrollMetrics(Direction.HORIZONTAL);
			_hPixScrollMetrics.scrollMetricsChanged.addHandler(onScrollChange);
			
			_layout.measurementsChanged.addHandler(onLayoutMeasChange);
			_layout.addRendererAct.addHandler(onAddRenderer);
			_layout.removeRendererAct.addHandler(onRemoveRenderer);
			
			_mouseWheelScroller = new MouseWheelScroller();
			_mouseDragScroller = new MouseDragScroller();
		}
		protected function createLayout() : void{
			_layout = new RendererGridLayout(this);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			var scrollBarAsset:IDisplayObject = _containerAsset.takeAssetByName(AssetNames.SCROLL_BAR,true);
			if(scrollBarAsset){
				if(!_scrollBar){
					_scrollBar = new ScrollBar();
					_scrollBar.hideWhenUnusable = _hideScrollBarWhenUnusable;
				}
				_scrollBar.asset = scrollBarAsset;
				_scrollBar.scrollSubject = this;
				setScrollBarMetrics(_layout.getScrollMetrics(_scrollBar.direction));
			}
			_assumedRendererAsset = _containerAsset.takeAssetByName(assumedRendererAssetName(),true);
			if(_assumedRendererAsset){
				_containerAsset.removeAsset(_assumedRendererAsset);
				assessFactory();
			}
			_container = _containerAsset.factory.createContainer();
			_containerAsset.addAsset(_container);
			
			var wheelDirection:String;
			if(scrollBarAsset){
				wheelDirection = _scrollBar.direction;
			}else if(_layout.pixelFlow){
				wheelDirection = (_layout.flowDirection==Direction.HORIZONTAL?Direction.VERTICAL:Direction.VERTICAL);
			}else{
				wheelDirection = _layout.flowDirection;
			}
			var scrollMet:IScrollMetrics = getScrollMetrics(wheelDirection);
			_mouseWheelScroller.scrollMetrics = new ScrollMultiplier(30,scrollMet);
			_mouseWheelScroller.interactiveObject = _interactiveObjectAsset;
			_mouseDragScroller.scrollMetrics = scrollMet;
			_mouseDragScroller.interactiveObject = _interactiveObjectAsset;
		}
		protected function setScrollBarMetrics(scrollMetrics:IScrollMetrics):void{
			if(_scrollMetrics!=scrollMetrics){
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.removeHandler(onScrollMetricsChanged);
				}
				_scrollMetrics = scrollMetrics;
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.addHandler(onScrollMetricsChanged);
				}
				invalidateMeasurements();
				invalidateSize();
			}
		}
		protected function onScrollMetricsChanged(from:IScrollMetrics) : void{
			invalidateMeasurements();
			invalidateSize();
		}
		protected function assumedRendererAssetName() : String{
			return AssetNames.LIST_ITEM;
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
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
					_assumedRendererFactory.objectProps = null;
					_assumedRendererFactory = null;
					assessFactory();
				}
			}
			_containerAsset.removeAsset(_container);
			_containerAsset.factory.destroyAsset(_container);
			_container = null;
			
			_mouseWheelScroller.interactiveObject = null;
			_mouseDragScroller.interactiveObject = null;
		}
		protected function onLayoutMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number) : void{
			invalidateMeasurements();
		}
		protected function onAddRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
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
			// TODO: this functionality should really be part of some factory.destory(item) method or something
			var view:DrawableView = (renderer as DrawableView);
			if(view)view.asset = null;
		}
		override protected function measure() : void{
			assessFactory();
			var layoutMeas:Point = _layout.measurements;
			
			_measurements.x = layoutMeas.x;
			_measurements.y = layoutMeas.y;
			if(_scrollBar){
				var metrics:IScrollMetrics = _scrollBar.scrollSubject.getScrollMetrics(_scrollBar.direction);
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
		override protected function commitSize() : void{
			super.commitSize();
			drawListAndScrollbar(size.x,size.y);
		}
		
		protected function drawListAndScrollbar(width:Number, height:Number) : void{
			var layoutWidth:Number = width;
			var layoutHeight:Number = height;
			if(_scrollBar){
				var meas:Point = _scrollBar.measurements;
				var metrics:IScrollMetrics = _scrollBar.scrollSubject.getScrollMetrics(_scrollBar.direction);
				_scrollBarShown = (metrics.maximum>metrics.pageSize || !_scrollBar.hideWhenUnusable);
				if(_scrollBar.direction==Direction.VERTICAL){
					_scrollBar.setPosition(width-meas.x-_layout.marginRight,_layout.marginTop);
					_scrollBar.setSize(meas.x,height-_layout.marginTop-_layout.marginBottom);
					if(_scrollBarShown){
						layoutWidth = width-meas.x;
					}
				}else{
					_scrollBar.setPosition(_layout.marginLeft,height-meas.y-_layout.marginBottom);
					_scrollBar.setSize(width-_layout.marginLeft-_layout.marginRight,meas.y);
					if(_scrollBarShown){
						layoutHeight = height-meas.y;
					}
				}
			}
			setLayoutDimensions(layoutWidth,layoutHeight);
			commitScrollRect();
		}
		protected function setDirection(value:String):void{
			_layout.flowDirection = value;
			if(value==Direction.HORIZONTAL){
				_layout.equaliseCellHeights = true;
				_layout.equaliseCellWidths = false;
			}else{
				_layout.equaliseCellHeights = false;
				_layout.equaliseCellWidths = true;
			}
			if(_scrollBar)_scrollBar.direction = value;
		}
		protected function setLayoutDimensions(width:Number, height:Number):void{
			_layout.setSize(width,height);
			/*if(_layout.flowDirection==Direction.VERTICAL){
				_layout.columnWidths = [width-_layout.marginLeft-_layout.marginRight];
				_layout.rowHeights = null;
			}else{
				_layout.columnWidths = null;
				_layout.rowHeights = [height-_layout.marginTop-_layout.marginBottom];
			}*/
		}
		protected function onScrollChange(from:IScrollMetrics):void{
			if(isBound)commitScrollRect();
		}
		
		protected function commitScrollRect():void{
			if(_alwaysUseScrollRect ||
				_hPixScrollMetrics.pageSize<_hPixScrollMetrics.maximum-_hPixScrollMetrics.minimum ||
				_vPixScrollMetrics.pageSize<_vPixScrollMetrics.maximum-_vPixScrollMetrics.minimum){
			
				_scrollRect.x = _layout.marginLeft+_hPixScrollMetrics.scrollValue;
				_scrollRect.y = _layout.marginTop+_vPixScrollMetrics.scrollValue;
				_scrollRect.width = _layout.size.x-_layout.marginLeft-_layout.marginRight;
				_scrollRect.height = _layout.size.y-_layout.marginTop-_layout.marginBottom;
				
				_container.setPosition(_layout.marginLeft,_layout.marginTop);
				_container.scrollRect = _scrollRect;
			}else{
				
				_container.setPosition(0,0);
				_container.scrollRect = null;
			}
		}
		
		protected function assessFactory():void{
			attemptInit();
			
			var factory:IInstanceFactory;
			var dataField:String;
			if(_rendererFactory){
				factory = _rendererFactory;
				dataField = _dataField || ASSUMED_DATA_FIELD;
				
				var castFactory:InstanceFactory = (factory as InstanceFactory);
				if(castFactory && (!castFactory.objectProps || castFactory.objectProps["asset"]==null) && _assumedRendererAsset){
					if(!_assumedAssetProxyFactory){
						_assumedAssetProxyFactory = new ProxyInstanceFactory(_rendererFactory,null,true);
					}
					checkAssetFactory();
					_assumedAssetProxyFactory.addProp("asset", _assumedAssetFactory);
					factory = _assumedAssetProxyFactory;
				}
			}else if(_assumedRendererAsset){
				if(!_assumedRendererFactory){
					_assumedRendererFactory = createAssumedFactory();
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
		protected function createAssumedFactory():InstanceFactory{
			var factory:InstanceFactory = new InstanceFactory(getAssumedRendererClass(),null,true);
			checkAssetFactory();
			factory.addProp("asset", _assumedAssetFactory);
			return factory;
		}
		protected function getAssumedRendererClass():Class{
			return ListRenderer;
		}
		protected function checkAssetFactory():void{
			if(!_assumedAssetFactory && _assumedRendererAsset){
				_assumedAssetFactory = createAssumedAssetFactory(_assumedRendererAsset);
			}
		}
		protected function createAssumedAssetFactory(asset:IDisplayObject):IInstanceFactory{
			return asset.getCloneFactory();
		}
		protected function updateFactory(factory:IInstanceFactory, dataField:String):void{
			_layout.rendererFactory = factory;
			_layout.dataField = dataField;
		}
		
		public function getScrollMetrics(direction:String):IScrollMetrics{
			attemptInit();
			if(direction==Direction.HORIZONTAL){
				return _hScrollMetrics;
			}else{
				return _vScrollMetrics;
			}
		}
		protected function scrollSpeed(direction:String):Number{
			return 30;
		}
	}
}