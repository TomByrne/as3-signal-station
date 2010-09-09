package org.farmcode.core
{
	import flash.geom.Rectangle;
	
	import org.farmcode.binding.PropertyWatcher;
	import org.farmcode.data.core.StringData;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.debug.DebugManager;
	import org.farmcode.debug.data.baseMetrics.GarbageCollect;
	import org.farmcode.debug.data.baseMetrics.IntendedFrameRate;
	import org.farmcode.debug.data.baseMetrics.MemoryUsage;
	import org.farmcode.debug.data.baseMetrics.RealFrameRate;
	import org.farmcode.debug.data.core.DebugData;
	import org.farmcode.debug.nodes.DebugDataNode;
	import org.farmcode.debug.nodes.GraphStatisticNode;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IStageAsset;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.core.LayoutView;
	import org.farmcode.display.core.ScopedObject;
	import org.farmcode.math.units.MemoryUnitConverter;
	
	/**
	 * Application adds the core abstract implementation of the IApplication
	 * interface.
	 */
	public class Application implements IApplication
	{
		public function get container():IContainerAsset{
			return _container;
		}
		public function set container(value:IContainerAsset):void{
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
		protected var _asset:IDisplayAsset;
		protected var _container:IContainerAsset;
		protected var _lastStage:IStageAsset;
		protected var _inited:Boolean;
		protected var _displayPosition:Rectangle;
		protected var _assumedMainAsset:Boolean;
		protected var _assetWatcher:PropertyWatcher;
		protected var _stageWatcher:PropertyWatcher;
		protected var _scopedObject:ScopedObject;
		
		public function Application(){
			super();
			_displayPosition = new Rectangle();
		}
		final protected function attemptInit() : void{
			if(!_inited){
				_inited = true;
				init();
			}
		}
		protected function init():void{
			_assetWatcher = new PropertyWatcher("asset",setAsset);
			_stageWatcher = new PropertyWatcher("stage",setStage,null,null,_container);
			_scopedObject = new ScopedObject();
			
			Config::DEBUG{
				var memory:INumberProvider = new MemoryUnitConverter(new MemoryUsage(),MemoryUnitConverter.BYTES,MemoryUnitConverter.MEGABYTES)
				DebugManager.addDebugNode(new GraphStatisticNode(_scopedObject,"Mem",0x009900,memory,true));
				
				var fps:GraphStatisticNode = new GraphStatisticNode(_scopedObject,"FPS",0x990000,new RealFrameRate(),true);
				fps.maximumProvider = new IntendedFrameRate(_scopedObject);
				DebugManager.addDebugNode(fps);
				DebugManager.addDebugNode(new DebugDataNode(_scopedObject,new DebugData(new StringData("Garbage Collect"),new GarbageCollect())));
			}
		}
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			_displayPosition.x = x;
			_displayPosition.y = y;
			_displayPosition.width = width;
			_displayPosition.height = height;
			if(_asset)setMainViewSize();
		}
		protected function attemptSetAssumedAsset():void{
			if(_castMainView && !_castMainView.asset){
				var asset:IDisplayAsset = getAssumedAsset();
				if(asset){
					_assumedMainAsset = true;
					_castMainView.asset = asset;
				}
			}
		}
		protected function getAssumedAsset():IDisplayAsset{
			// override me
			return null;
		}
		protected function removeMainAsset():void{
			if(_container && _asset){
				_container.removeAsset(_asset);
			}
		}
		protected function addMainAsset():void{
			if(_container && _asset){
				_container.addAsset(_asset);
				if(_displayPosition)setMainViewSize();
			}
		}
		protected function setAsset(value:IDisplayAsset) : void{
			removeMainAsset();
			_asset = value;
			_scopedObject.asset = value;
			addMainAsset();
		}
		private function setStage(value:IStageAsset) : void{
			if(_lastStage!=value){
				_lastStage = value;
				commitStage();
			}
		}
		protected function commitStage() : void{
			// override me
		}
		protected function setMainViewSize() : void{
			// If FullscreenUtil is being used then this will be skipped
			if(_asset.parent==_container){
				var scale:Number = (isNaN(_applicationScale) || _applicationScale<=0?1:_applicationScale);
				var pos:Rectangle = _displayPosition;
				_mainView.setDisplayPosition(pos.x,pos.y,pos.width*(1/scale),pos.height*(1/scale));
				_asset.scaleX = scale;
				_asset.scaleY = scale;
			}
		}
	}
}