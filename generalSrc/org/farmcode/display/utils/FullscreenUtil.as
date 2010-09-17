package org.farmcode.display.utils
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IStageAsset;
	import org.farmcode.display.core.ILayoutView;

	public class FullscreenUtil
	{
		
		public function get view():ILayoutView{
			return _view;
		}
		public function set view(value:ILayoutView):void{
			if(_view!=value){
				if(_view && _active && _view.asset){
					removeFullscreen();
				}
				_view = value;
				if(_view && _active && _view.asset){
					addFullscreen();
				}
			}
		}
		
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_active!=value){
				_active = value;
				if(_view && _view.asset){
					if(_active)addFullscreen();
					else removeFullscreen();
				}
				if(_activeChange)_activeChange.perform(this,_active);
			}
		}
		public function get fullScreenScale():Number{
			return _fullScreenScale;
		}
		public function set fullScreenScale(value:Number):void{
			if(_fullScreenScale != value){
				_fullScreenScale = value;
				if(active){
					checkSize();
				}
			}
		}
		
		/**
		 * handler(from:FullscreenUtil, active:Boolean)
		 */
		public function get activeChange():IAct{
			if(!_activeChange)_activeChange = new Act();
			return _activeChange;
		}
		
		protected var _activeChange:Act;
		
		public var stage:IStageAsset;
		
		private var _fullScreenScale:Number = 1;
		private var _active:Boolean;
		private var _view:ILayoutView;
		
		private var _oldParent:IContainerAsset;
		private var _oldDepth:int;
		private var _lastStage:IStageAsset;

		public function FullscreenUtil(view:ILayoutView=null){
			this.view = view;
		}
		protected function addFullscreen():void{
			_lastStage = (stage?stage:_view.asset.stage);
			_oldParent = _view.asset.parent;
			if(_oldParent){
				_oldDepth = _oldParent.getAssetIndex(_view.asset);
				_oldParent.removeAsset(_view.asset);
			}
			TopLayerManager.add(_view.asset,_lastStage);
			checkSize();
			
			_lastStage.resize.addHandler(onResize);
			_lastStage.displayState = StageDisplayState.FULL_SCREEN;
			_lastStage.fullScreen.addHandler(onFullScreen);
		}
		protected function removeFullscreen():void{
			_lastStage.resize.removeHandler(onResize);
			_lastStage.fullScreen.removeHandler(onFullScreen);
			
			_lastStage.displayState = StageDisplayState.NORMAL;
			
			_lastStage = null;
			TopLayerManager.remove(_view.asset);
			if(_oldParent){
				_oldParent.addAssetAt(_view.asset,_oldDepth);
			}
			_oldParent = null;
		}
		protected function onResize(e:Event, from:IStageAsset):void{
			checkSize();
		}
		protected function checkSize():void{
			_view.setDisplayPosition(0,0,_lastStage.stageWidth/_fullScreenScale,_lastStage.stageHeight/_fullScreenScale);
			_view.asset.scaleX = _fullScreenScale;
			_view.asset.scaleY = _fullScreenScale;
		}
		protected function onFullScreen(e:Event, from:IStageAsset):void{
			active = (from.displayState==StageDisplayState.FULL_SCREEN);
		}
	}
}