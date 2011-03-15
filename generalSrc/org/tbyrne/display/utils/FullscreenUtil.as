package org.tbyrne.display.utils
{
	import flash.display.StageDisplayState;
	import flash.geom.Point;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.DelayedCall;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.IOutroView;
	import org.tbyrne.display.core.IView;

	public class FullscreenUtil
	{
		private static var ORIGIN:Point = new Point();
		
		/**
		 * handler(from:FullscreenUtil, active:Boolean)
		 */
		public function get activeChange():IAct{
			if(!_activeChange)_activeChange = new Act();
			return _activeChange;
		}
		
		
		
		public function get view():ILayoutView{
			return _view;
		}
		public function set view(value:ILayoutView):void{
			if(_view!=value){
				_view = value;
				_outroView = (_view as IOutroView);
				
				if(_addedView){
					removeFullscreen();
				}else if(_view && _active && _parent){
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
				if(_activeConsumer){
					_activeConsumer.booleanValue = value;
				}
				if(_active){
					if(_view && _parent){
						addFullscreen();
					}
				}else if(_addedView){
					removeFullscreen();
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
					checkStageSize();
				}
			}
		}
		
		/**
		 * This can help keep multiple components in sync easily (e.g. VideoContainer)
		 */
		public function get activeProvider():IBooleanProvider{
			return _activeProvider;
		}
		public function set activeProvider(value:IBooleanProvider):void{
			if(_activeProvider!=value){
				if(_activeProvider){
					_activeProvider.booleanValueChanged.removeHandler(onBooleanValueChanged);
				}
				_activeProvider = value;
				_activeConsumer = (value as IBooleanConsumer);
				if(_activeProvider){
					active = _activeProvider.booleanValue;
					_activeProvider.booleanValueChanged.addHandler(onBooleanValueChanged);
				}
			}
		}
		
		/**
		 * This can be set either to an IDisplayObjectContainer or an ILayoutView.
		 * 
		 * If it is set to the stage, the view will fill the stage.
		 * 
		 * If it is set to a different IDisplayObjectContainer, it will fill from the top-left of the
		 * IDisplayObjectContainer to the bottom-left of the stage.
		 * 
		 * If it is set to an ILayoutView, it will fill that ILayoutView.
		 */
		public function get parent():*{
			return _parent;
		}
		public function set parent(value:*):void{
			if(_parent!=value){
				_parent = value;
				if(_addedView){
					removeFullscreen();
				}
			}
		}
		
		public function get syncWithStageFullScreen():Boolean{
			return _syncWithStageFullScreen;
		}
		public function set syncWithStageFullScreen(value:Boolean):void{
			if(_syncWithStageFullScreen!=value){
				_syncWithStageFullScreen = value;
				if(_addedView){
					if(_syncWithStageFullScreen){
						_addedStage.displayState = StageDisplayState.FULL_SCREEN;
					}else{
						_addedStage.displayState = StageDisplayState.NORMAL;
					}
				}
			}
		}
		
		private var _activeProvider:IBooleanProvider;
		private var _activeConsumer:IBooleanConsumer;
		private var _syncWithStageFullScreen:Boolean=true;
		
		protected var _activeChange:Act;
		
		private var _fullScreenScale:Number = 1;
		private var _active:Boolean;
		
		private var _parent:*;
		private var _view:ILayoutView;
		private var _outroView:IOutroView;
		
		private var _addedView:ILayoutView;
		private var _addedParent:IDisplayObjectContainer;
		private var _addedParentView:ILayoutView;
		private var _addedStage:IStage;
		
		/*
			These relate to the view's properties before it was added
		*/
		private var _oldParent:IDisplayObjectContainer;
		private var _oldDepth:int;
		private var _oldX:Number;
		private var _oldY:Number;
		private var _oldWidth:Number;
		private var _oldHeight:Number;
		
		//private var _pendingAdd:DelayedCall;

		public function FullscreenUtil(view:ILayoutView=null){
			this.view = view;
		}
		protected function onBooleanValueChanged(from:IBooleanProvider):void{
			active = from.booleanValue;
		}
		protected function addFullscreen():void{
			// collect infor about the view before messing with it
			_oldParent = view.asset.parent;
			if(_oldParent){
				_oldDepth = _oldParent.getAssetIndex(view.asset);
				_oldParent.removeAsset(view.asset);
			}
			_oldX = _view.position.x;
			_oldY = _view.position.y;
			_oldWidth = _view.size.x;
			_oldHeight = _view.size.y;
			
			// work out where and how we intend to add it.
			_addedView = _view;
			_addedParentView = (_parent as ILayoutView);
			if(_addedParentView){
				_addedParent = _parent.asset as IDisplayObjectContainer;
				_addedStage = _addedParent.stage as IStage;
				_addedParentView.sizeChanged.addHandler(onParentViewSizeChanged);
				_addedView.setPosition(0,0);
				_addedView.setSize(_addedParentView.size.x,_addedParentView.size.y);
			}else{
				_addedParent = _parent as IDisplayObjectContainer;
				_addedStage = _addedParent.stage as IStage;
				_addedStage.resize.addHandler(onStageResize);
				checkStageSize();
			}
			if(_syncWithStageFullScreen){
				_addedStage.displayState = StageDisplayState.FULL_SCREEN;
				_addedStage.fullScreen.addHandler(onFullScreen);
			}
			TopLayerManager.add(view.asset,_addedParent);
		}
		
		protected function removeFullscreen():Number{
			if(_syncWithStageFullScreen){
				_addedStage.fullScreen.removeHandler(onFullScreen);
				_addedStage.displayState = StageDisplayState.NORMAL;
			}
			
			var ret:Number;
			if(_outroView){
				ret = _outroView.showOutro()
				var removeCall:DelayedCall = new DelayedCall(finaliseRemove,ret,true);
				removeCall.begin();
			}else{
				finaliseRemove();
				ret = 0;
			}
			return ret;
		}
		protected function finaliseRemove():void{
			if(_addedParentView){
				_addedParentView.sizeChanged.removeHandler(onParentViewSizeChanged);
			}else{
				_addedStage.resize.removeHandler(onStageResize);
			}
			TopLayerManager.remove(_addedView.asset);
			if(_oldParent){
				_oldParent.addAssetAt(_addedView.asset,_oldDepth);
				_oldParent = null;
			}
			_addedView.setPosition(_oldX,_oldY);
			_addedView.setSize(_oldWidth,_oldHeight);
			
			_addedView = null;
			_addedStage = null;
			_addedParent = null;
			_addedParentView = null;
			
			if(_view && _active && _parent){
				addFullscreen();
			}
		}
		
		protected function onStageResize(from:IStage):void{
			checkStageSize();
		}
		protected function checkStageSize():void{
			var offset:Point;
			if(_addedParent!=_addedStage){
				offset = _addedParent.localToGlobal(ORIGIN);
			}else{
				offset = ORIGIN;
			}
			_view.setSize((_addedStage.stageWidth-offset.x)/_fullScreenScale,(_addedStage.stageHeight-offset.y)/_fullScreenScale);
			_view.asset.scaleX = _fullScreenScale;
			_view.asset.scaleY = _fullScreenScale;
		}
		protected function onFullScreen(from:IStage):void{
			active = (from.displayState==StageDisplayState.FULL_SCREEN);
		}
		
		protected function onParentViewSizeChanged(from:ILayoutView, oldWidth:Number, oldHeight:Number):void{
			_addedView.setSize(_addedParentView.size.x,_addedParentView.size.y);
		}
	}
}