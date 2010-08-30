package org.farmcode.core
{
	import flash.geom.Rectangle;
	
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.debug.DebugManager;
	import org.farmcode.debug.data.core.MemoryUsage;
	import org.farmcode.debug.data.core.RealFrameRate;
	import org.farmcode.debug.nodes.GraphStatisticNode;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IStageAsset;
	import org.farmcode.display.core.LayoutView;
	import org.farmcode.math.units.MemoryUnitConverter;
	
	/**
	 * Application adds the core abstract implementation of the IApplication
	 * interface.
	 */
	// TODO: remove LayoutView inheritance?
	public class Application extends LayoutView implements IApplication
	{
		public function get container():IContainerAsset{
			return _container;
		}
		public function set container(value:IContainerAsset):void{
			if(_container!=value){
				removeMainDisplay();
				_container = value;
				
				if(value){
					setStage(_container.stage);
				}else{
					setStage(null);
				}
				addMainDisplay();
			}
		}
		override public function set asset(value:IDisplayAsset):void{
			if(super.asset!=value){
				removeMainDisplay();
				super.asset = value;
				addMainDisplay();
			}
		}
		
		public function get mainView():LayoutView{
			return _mainView;
		}
		public function set mainView(value:LayoutView):void{
			if(_mainView!=value){
				if(_mainView){
					if(_mainView.asset==asset)_mainView.asset = null;
				}
				_mainView = value;
				if(_mainView){
					if(!_mainView.asset)_mainView.asset = asset;
					invalidate()
				}
			}
		}
		
		public function get applicationScale():Number{
			return _applicationScale;
		}
		public function set applicationScale(value:Number):void{
			if(_applicationScale!=value){
				_applicationScale = value;
				invalidate();
			}
		}
		
		private var _applicationScale:Number = 1;
		private var _mainView:LayoutView;
		protected var _container:IContainerAsset;
		protected var _lastStage:IStageAsset;
		
		public function Application(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init():void{
			super.init();
			Config::DEBUG{
				DebugManager.addDebugNode(new GraphStatisticNode(this,"FPS",0x990000,new RealFrameRate(),true));
				var memory:INumberProvider = new MemoryUnitConverter(new MemoryUsage(),MemoryUnitConverter.BYTES,MemoryUnitConverter.MEGABYTES,true)
				DebugManager.addDebugNode(new GraphStatisticNode(this,"Mem",0x009900,memory,true));
			}
		}
		protected function removeMainDisplay():void{
			if(asset && _container){
				_container.removeAsset(asset);
			}
		}
		protected function addMainDisplay():void{
			if(asset && _container){
				_container.addAsset(asset);
			}
		}
		override protected function bindToAsset() : void{
			setStage(asset.stage);
			if(_mainView && !_mainView.asset){
				_mainView.asset = asset;
			}
			super.bindToAsset();
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			if(_mainView && _mainView.asset==asset){
				_mainView.asset = null;
			}
			setStage(null);
		}
		protected function setStage(value:IStageAsset) : void{
			if(_lastStage!=value){
				_lastStage = value;
				commitStage();
			}
		}
		protected function commitStage() : void{
			// override me
		}
		override protected function draw() : void{
			// If FullscreenUtil is being used then this will be skipped
			if(_mainView && _mainView.asset.parent==_container){
				var scale:Number = (isNaN(_applicationScale) || _applicationScale<=0?1:_applicationScale);
				var pos:Rectangle = displayPosition;
				_mainView.setDisplayPosition(pos.x,pos.y,pos.width*(1/scale),pos.height*(1/scale));
				asset.scaleX = scale;
				asset.scaleY = scale;
			}
		}
	}
}