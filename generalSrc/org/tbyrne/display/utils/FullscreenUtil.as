package org.tbyrne.display.utils
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.geom.Point;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.DelayedCall;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.IOutroView;
	import org.tbyrne.display.core.IView;

	public class FullscreenUtil
	{
		private static var ORIGIN:Point = new Point();
		
		
		public function get view():ILayoutView{
			return _view;
		}
		public function set view(value:ILayoutView):void{
			if(_view!=value){
				var delay:Number;
				if(_view && _active && _view.asset){
					if(_pendingAdd){
						_pendingAdd.clear();
						delay = 0;
					}else{
						delay = removeFullscreen();
					}
				}else{
					delay = 0;
				}
				_view = value;
				_outroView = (_view as IOutroView);
				if(_view && _active && _view.asset){
					addFullscreen(delay);
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
					if(_active)addFullscreen(0);
					else if(_pendingAdd){
						_pendingAdd.clear();
					}else{
						removeFullscreen();
					}
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
		
		
		public function get stage():IStage{
			return _stage;
		}
		public function set stage(value:IStage):void{
			if(_stage!=value){
				var wasActive:Boolean = active;
				if(wasActive)active = false;
				_stage = value;
				if(wasActive)active = true;
			}
		}
		
		public function get parentContainer():IDisplayObjectContainer{
			return _parentContainer;
		}
		public function set parentContainer(value:IDisplayObjectContainer):void{
			if(_parentContainer!=value){
				var wasActive:Boolean = active;
				if(wasActive)active = false;
				_parentContainer = value;
				if(wasActive)active = true;
			}
		}
		
		private var _parentContainer:IDisplayObjectContainer;
		private var _stage:IStage;
		
		/**
		 * handler(from:FullscreenUtil, active:Boolean)
		 */
		public function get activeChange():IAct{
			if(!_activeChange)_activeChange = new Act();
			return _activeChange;
		}
		
		protected var _activeChange:Act;
		
		private var _fullScreenScale:Number = 1;
		private var _active:Boolean;
		private var _view:ILayoutView;
		private var _outroView:IOutroView;
		
		
		private var _oldParent:IDisplayObjectContainer;
		private var _oldDepth:int;
		private var _lastContainer:IDisplayObjectContainer;
		private var _lastStage:IStage;
		private var _pendingAdd:DelayedCall;

		public function FullscreenUtil(view:ILayoutView=null){
			this.view = view;
		}
		protected function addFullscreen(delay:Number):void{
			if(delay){
				_pendingAdd = new DelayedCall(finaliseAdd,delay,true,[_view]);
				_pendingAdd.begin();
			}else{
				finaliseAdd(_view);
			}
		}
		
		private function finaliseAdd(view:ILayoutView):void{
			_lastStage = (stage?stage:(view.asset.stage?view.asset.stage:_parentContainer.stage));
			_lastContainer = (_parentContainer?_parentContainer:_lastStage);
			_oldParent = view.asset.parent;
			if(_oldParent){
				_oldDepth = _oldParent.getAssetIndex(view.asset);
				_oldParent.removeAsset(view.asset);
			}
			TopLayerManager.add(view.asset,_lastContainer);
			checkSize();
			
			_lastStage.resize.addHandler(onResize);
			if(stage){
				stage.displayState = StageDisplayState.FULL_SCREEN;
				stage.fullScreen.addHandler(onFullScreen);
			}
			
			_pendingAdd = null;
		}
		
		protected function removeFullscreen():Number{
			_lastStage.resize.removeHandler(onResize);
			if(stage){
				stage.fullScreen.removeHandler(onFullScreen);
				stage.displayState = StageDisplayState.NORMAL;
			}
			
			_lastStage = null;
			_lastContainer = null;
			
			var ret:Number;
			if(_outroView){
				ret = _outroView.showOutro()
				var removeCall:DelayedCall = new DelayedCall(finaliseRemove,ret,true,[_view,_oldDepth,_oldParent]);
				removeCall.begin();
			}else{
				finaliseRemove(_view,_oldDepth,_oldParent);
				ret = 0;
			}
			_oldParent = null;
			return ret;
		}
		protected function finaliseRemove(view:IView, oldDepth:int, oldParent:IDisplayObjectContainer):void{
			TopLayerManager.remove(view.asset);
			if(_oldParent){
				oldParent.addAssetAt(view.asset,oldDepth);
			}
		}
		protected function onResize(from:IStage):void{
			checkSize();
		}
		protected function checkSize():void{
			var offset:Point;
			if(_lastContainer!=_lastStage){
				offset = _lastContainer.localToGlobal(ORIGIN);
			}else{
				offset = ORIGIN;
			}
			_view.setSize((_lastStage.stageWidth-offset.x)/_fullScreenScale,(_lastStage.stageHeight-offset.y)/_fullScreenScale);
			_view.asset.scaleX = _fullScreenScale;
			_view.asset.scaleY = _fullScreenScale;
		}
		protected function onFullScreen(from:IStage):void{
			active = (from.displayState==StageDisplayState.FULL_SCREEN);
		}
	}
}