package org.farmcode.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IStageAsset;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.core.LayoutView;
	import org.farmcode.display.core.View;
	
	/**
	 * Application adds the core abstract implementation of the IApplication
	 * interface.
	 */
	public class Application extends LayoutView implements IApplication
	{
		public function get container():DisplayObjectContainer{
			return _container;
		}
		public function set container(value:DisplayObjectContainer):void{
			if(_container!=value){
				removeMainDisplay();
				_container = value;
				
				if(value){
					_assetContainer = NativeAssetFactory.getNew(value);
					setStage(_assetContainer.stage);
					if(value==value.stage)attemptInit();
				}else{
					_assetContainer = null
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
		protected var _container:DisplayObjectContainer;
		protected var _assetContainer:IContainerAsset;
		protected var _lastStage:IStageAsset;
		
		public function Application(asset:IDisplayAsset=null){
			super(asset);
		}
		protected function removeMainDisplay():void{
			if(asset && _assetContainer){
				_assetContainer.removeAsset(asset);
			}
		}
		protected function addMainDisplay():void{
			if(asset && _assetContainer){
				_assetContainer.addAsset(asset);
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
		override public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			super.setDisplayPosition(x, y, width, height);
		}
		override protected function draw() : void{
			// If FullscreenUtil is being used then this will be skipped
			if(_mainView && _mainView.asset.parent==_assetContainer){
				var scale:Number = (isNaN(_applicationScale) || _applicationScale<=0?1:_applicationScale);
				var pos:Rectangle = displayPosition;
				_mainView.setDisplayPosition(pos.x,pos.y,pos.width*(1/scale),pos.height*(1/scale));
				asset.scaleX = scale;
				asset.scaleY = scale;
			}
		}
	}
}