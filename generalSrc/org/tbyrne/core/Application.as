package org.tbyrne.core
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.binding.PropertyWatcher;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.debug.DebugManager;
	import org.tbyrne.debug.data.baseMetrics.GarbageCollect;
	import org.tbyrne.debug.data.baseMetrics.IntendedFrameRate;
	import org.tbyrne.debug.data.baseMetrics.MemoryUsage;
	import org.tbyrne.debug.data.baseMetrics.RealFrameRate;
	import org.tbyrne.debug.data.core.DebugData;
	import org.tbyrne.debug.nodes.DebugDataNode;
	import org.tbyrne.debug.nodes.GraphStatisticNode;
	import org.tbyrne.debug.nodes.StandardNodePaths;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.display.core.ScopedObject;
	import org.tbyrne.input.items.MethodCallInputItem;
	import org.tbyrne.math.units.MemoryUnitConverter;
	
	/**
	 * Application adds the core abstract implementation of the IApplication
	 * interface.
	 */
	/*[SWF(width=1000, height=750, frameRate=30, backgroundColor="#ffffff")]
	[Frame(factoryClass="org.tbyrne.display.progress.SimpleSWFPreloaderFrame")] */ // this must be on subclass
	public class Application implements IApplication
	{
		public function get container():IDisplayObjectContainer{
			return _container;
		}
		public function set container(value:IDisplayObjectContainer):void{
			if(_container!=value){
				removeMainAsset();
				_container = value;
				if(_stageWatcher)_stageWatcher.bindable = value;
				addMainAsset();
			}
		}
		
		public function get mainView():ILayoutView{
			return _mainView;
		}
		public function set mainView(value:ILayoutView):void{
			if(_mainView!=value){
				attemptInit();
				if(_mainView){
					if(_assumedMainAsset){
						_castMainView.asset = null;
						_assumedMainAsset = false;
					}
					removeMainAsset();
				}
				_mainView = value;
				_assetWatcher.bindable = value;
				_castMainView = (value as LayoutView);
				
				if(_mainView){
					attemptSetAssumedAsset();
					addMainAsset();
				}
			}
		}
		
		public function get applicationScale():Number{
			return _applicationScale;
		}
		public function set applicationScale(value:Number):void{
			if(_applicationScale!=value){
				_applicationScale = value;
				if(_asset)setMainViewSize();
			}
		}
		
		private var _applicationScale:Number = 1;
		
		protected var _mainView:ILayoutView;
		protected var _castMainView:LayoutView;
		protected var _asset:IDisplayObject;
		protected var _container:IDisplayObjectContainer;
		protected var _lastStage:IStage;
		protected var _inited:Boolean;
		protected var _position:Point;
		protected var _size:Point;
		protected var _assumedMainAsset:Boolean;
		protected var _assetWatcher:PropertyWatcher;
		protected var _stageWatcher:PropertyWatcher;
		protected var _scopedObject:ScopedObject;
		protected var _mainAssetAdded:Boolean;
		
		public function Application(){
			super();
		}
		final protected function attemptInit() : void{
			if(!_inited){
				_inited = true;
				init();
			}
		}
		protected function init():void{
			_scopedObject = new ScopedObject(_asset);
			_assetWatcher = new PropertyWatcher("asset",setAsset);
			_stageWatcher = new PropertyWatcher("stage",setStage,null,null,_container);
			
			CONFIG::debug{
				var memory:INumberProvider = new MemoryUnitConverter(new MemoryUsage(),MemoryUnitConverter.BYTES,MemoryUnitConverter.MEGABYTES)
				DebugManager.addDebugNode(new GraphStatisticNode(_scopedObject,"Mem",0x009900,memory,true));
				
				var fps:GraphStatisticNode = new GraphStatisticNode(_scopedObject,"FPS",0x990000,new RealFrameRate(),true);
				fps.maximumProvider = new IntendedFrameRate(_scopedObject);
				DebugManager.addDebugNode(fps);
				DebugManager.addDebugNode(new DebugDataNode(_scopedObject,StandardNodePaths.GARBAGE_COLLECT,new DebugData(new StringData("Garbage Collect"),new GarbageCollect())));
				
			}

		}
		CONFIG::debug{
		PLATFORM::air{
		public function setResolution(x:Number, y:Number):void{
				var bounds:Rectangle = _lastStage.nativeWindow.bounds;
				var xDif:Number = bounds.width-_size.x;
				var yDif:Number = bounds.height-_size.y;
				
				bounds.width = x+xDif;
				bounds.height = y+yDif;
				
				_lastStage.nativeWindow.bounds = bounds;
		}
		}
		}
		public function setPosition(x:Number, y:Number):void{
			if(!_position)_position = new Point();
			_position.x = x;
			_position.y = y;
			if(_asset)setMainViewPos();
		}
		public function setSize(width:Number, height:Number):void{
			if(!_size)_size = new Point();
			_size.x = width;
			_size.y = height;
			if(_asset)setMainViewSize();
		}
		protected function attemptSetAssumedAsset():void{
			if(_castMainView && !_castMainView.asset){
				var asset:IDisplayObject = getAssumedAsset();
				if(asset){
					_assumedMainAsset = true;
					_castMainView.asset = asset;
				}
			}
		}
		protected function getAssumedAsset():IDisplayObject{
			// override me
			return null;
		}
		protected function removeMainAsset():void{
			if(_mainAssetAdded && _container && _asset){
				_mainAssetAdded = false;
				_container.removeAsset(_asset);
			}
		}
		protected function addMainAsset():void{
			if(!_mainAssetAdded && _container && _asset){
				_mainAssetAdded = true;
				_container.addAssetAt(_asset,0);
				if(_size)setMainViewSize();
			}
		}
		protected function setAsset(value:IDisplayObject) : void{
			attemptInit();
			if(_asset){
				removeMainAsset();
				_asset.addedToStage.removeHandler(onAddedToStage);
			}
			_asset = value;
			if(_scopedObject)_scopedObject.asset = value;
			if(_asset){
				_asset.addedToStage.addHandler(onAddedToStage);
				addMainAsset();
			}
		}
		private function onAddedToStage(from:IAsset) : void{
			// after fullscreen is exited this will occur
			if(_size)setMainViewSize();
		}
		private function setStage(value:IStage) : void{
			if(_lastStage!=value){
				_lastStage = value;
				commitStage();
				PLATFORM::air{CONFIG::debug{
					if(_lastStage.nativeWindow.resizable){
						var resolution:DebugData = new DebugData(new StringData("Resolution"));
						resolution.addChildData(new DebugData(new StringData("640 x 480"),new MethodCallInputItem(null,setResolution,[640,480])));
						resolution.addChildData(new DebugData(new StringData("800 x 600"),new MethodCallInputItem(null,setResolution,[800,600])));
						resolution.addChildData(new DebugData(new StringData("1024 x 768"),new MethodCallInputItem(null,setResolution,[1024,768])));
						resolution.addChildData(new DebugData(new StringData("1280 x 720"),new MethodCallInputItem(null,setResolution,[1280,720])));
						resolution.addChildData(new DebugData(new StringData("1600 x 900"),new MethodCallInputItem(null,setResolution,[1600,900])));
						resolution.addChildData(new DebugData(new StringData("1280 x 1024"),new MethodCallInputItem(null,setResolution,[1280,1024])));
						DebugManager.addDebugNode(new DebugDataNode(_scopedObject,StandardNodePaths.RESOLUTION,resolution));
					}
				}}
			}
		}
		protected function commitStage() : void{
			// override me
		}
		protected function setMainViewPos() : void{
			var pos:Point = _position;
			// If FullscreenUtil is being used then this will be skipped
			if(pos && _asset.parent==_container && _mainView){
				_mainView.setPosition(pos.x,pos.y);
			}
		}
		protected function setMainViewSize() : void{
			// If FullscreenUtil is being used then this will be skipped
			var size:Point = _size;
			if(size && _asset.parent==_container && _mainView){
				var scale:Number = (isNaN(_applicationScale) || _applicationScale<=0?1:_applicationScale);
				_mainView.setSize(size.x*(1/scale),size.y*(1/scale));
				_asset.scaleX = scale;
				_asset.scaleY = scale;
			}
		}
	}
}