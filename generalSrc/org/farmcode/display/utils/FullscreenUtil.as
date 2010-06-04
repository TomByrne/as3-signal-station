package org.farmcode.display.utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
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
		
		public var stage:Stage;
		
		private var _active:Boolean;
		private var _view:ILayoutView;
		
		private var _oldParent:DisplayObjectContainer;
		private var _oldDepth:int;
		private var _lastStage:Stage;
		
		public function FullscreenUtil(view:ILayoutView=null){
			this.view = view;
		}
		public function addFullscreen():void{
			_oldParent = _view.asset.parent;
			if(_oldParent){
				_oldDepth = _oldParent.getChildIndex(_view.asset);
			}
			_lastStage = (stage?stage:_view.asset.stage);
			TopLayerManager.add(_view.asset,_lastStage);
			_view.setDisplayPosition(0,0,_lastStage.stageWidth,_lastStage.stageHeight);
			_lastStage.addEventListener(Event.RESIZE, onResize);
			_lastStage.displayState = StageDisplayState.FULL_SCREEN;
			_lastStage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
		}
		public function removeFullscreen():void{
			_lastStage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			_lastStage.removeEventListener(Event.RESIZE, onResize);
			_lastStage.displayState = StageDisplayState.NORMAL;
			_lastStage = null;
			TopLayerManager.remove(_view.asset);
			if(_oldParent){
				_oldParent.addChildAt(_view.asset,_oldDepth);
			}
			_oldParent = null;
		}
		public function onResize(e:Event):void{
			_view.setDisplayPosition(0,0,_lastStage.stageWidth,_lastStage.stageHeight);
		}
		public function onFullScreen(e:Event):void{
			active = false;
		}
	}
}