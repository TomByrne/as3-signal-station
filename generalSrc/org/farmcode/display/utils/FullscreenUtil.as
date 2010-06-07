package org.farmcode.display.utils
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IStageAsset;
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
		
		/**
		 * handler(from:FullscreenUtil, active:Boolean)
		 */
		public function get activeChange():IAct{
			if(!_activeChange)_activeChange = new Act();
			return _activeChange;
		}
		
		protected var _activeChange:Act;
		
		public var stage:IStageAsset;
		
		private var _active:Boolean;
		private var _view:ILayoutView;
		
		private var _oldParent:IContainerAsset;
		private var _oldDepth:int;
		private var _lastStage:IStageAsset;
		
		public function FullscreenUtil(view:ILayoutView=null){
			this.view = view;
		}
		public function addFullscreen():void{
			_oldParent = _view.asset.parent;
			if(_oldParent){
				_oldDepth = _oldParent.getAssetIndex(_view.asset);
			}
			_lastStage = (stage?stage:_view.asset.stage);
			TopLayerManager.add(_view.asset,_lastStage);
			_view.setDisplayPosition(0,0,_lastStage.stageWidth,_lastStage.stageHeight);
			_lastStage.displayState = StageDisplayState.FULL_SCREEN;
			_lastStage.resize.addHandler(onResize);
			_lastStage.fullScreen.addHandler(onFullScreen);
		}
		public function removeFullscreen():void{
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
		public function onResize(e:Event, from:IStageAsset):void{
			_view.setDisplayPosition(0,0,_lastStage.stageWidth,_lastStage.stageHeight);
		}
		public function onFullScreen(from:IStageAsset):void{
			active = false;
		}
	}
}