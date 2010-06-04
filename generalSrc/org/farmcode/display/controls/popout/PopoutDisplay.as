package org.farmcode.display.controls.popout
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IStageAsset;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.core.IOutroView;
	import org.farmcode.display.layout.ProxyLayoutSubject;
	import org.farmcode.display.layout.relative.RelativeLayout;
	import org.farmcode.display.layout.relative.RelativeLayoutInfo;
	import org.farmcode.display.utils.TopLayerManager;
	
	public class PopoutDisplay
	{
		public function get stage():IStageAsset{
			return _stage;
		}
		public function set stage(value:IStageAsset):void{
			_stage = value;
		}
		
		public function get popoutShown():Boolean{
			return _popoutShown;
		}
		public function set popoutShown(value:Boolean):void{
			if(value!=_popoutShown){
				_popoutShown = value;
				var wasRemoving:Boolean;
				if(_removeCall){
					wasRemoving = true;
					_removeCall.clear();
					_removeCall = null;
				}
				if(_popoutShown){
					if(!_popoutLayoutProxy){
						_popoutLayoutProxy = new ProxyLayoutSubject();
						_popoutLayoutProxy.layoutInfo = _relativeLayoutInfo;
					}
					_relativeLayout.addSubject(_popoutLayoutProxy);
					_relativeLayout.stage = _stage?_stage:relativeTo.stage;
					if(!_relativeLayout.stage){
						throw new Error("No reference to the stage found");
					}
					_popoutLayoutProxy.target = _popout;
					if(wasRemoving){
						// TopLayerManager.add will be ignored if it's doing it's outro
						TopLayerManager.remove(_popout.asset);
					}
					TopLayerManager.add(_popout.asset, _relativeLayout.stage);
					_added = true;
					if(_popoutOpen)_popoutOpen.perform(this,_popout);
				}else{
					_relativeLayout.removeSubject(_popoutLayoutProxy);
					_popoutLayoutProxy.target = null;
					if(_outroPopout){
						_removeCall = new DelayedCall(doRemove,_outroPopout.showOutro());
						_removeCall.begin();
					}else{
						_added = false;
						TopLayerManager.remove(_popout.asset);
					}
					if(_popoutClose)_popoutClose.perform(this,_popout);
				}
			}
		}
		
		public function get relativeTo():IDisplayAsset{
			return _relativeLayoutInfo.relativeTo;
		}
		public function set relativeTo(value:IDisplayAsset):void{
			_relativeLayoutInfo.relativeTo = value;
		}
		
		public function get popout():ILayoutView{
			return _popout;
		}
		public function set popout(value:ILayoutView):void{
			if(_popout!=value){
				var wasShown:Boolean = _popoutShown;
				popoutShown = false;
				_popout = value;
				_outroPopout = (value as IOutroView);
				popoutShown = wasShown;
				_popout.assetChanged.addHandler(onAssetChanged);
			}
		}
		
		
		public function get popoutLayoutInfo():RelativeLayoutInfo{
			return _relativeLayoutInfo;
		}
		public function get popoutLayout():RelativeLayout{
			return _relativeLayout;
		}
		
		
		/**
		 * handler(popoutDisplay:PopoutDisplay, popout:ILayoutView)
		 */
		public function get popoutOpen():IAct{
			if(!_popoutOpen)_popoutOpen = new Act();
			return _popoutOpen;
		}
		
		/**
		 * handler(popoutDisplay:PopoutDisplay, popout:ILayoutView)
		 */
		public function get popoutClose():IAct{
			if(!_popoutClose)_popoutClose = new Act();
			return _popoutClose;
		}
		
		protected var _popoutClose:Act;
		protected var _popoutOpen:Act;
		
		private var _added:Boolean;
		private var _stage:IStageAsset;
		private var _popout:ILayoutView;
		private var _outroPopout:IOutroView;
		private var _popoutShown:Boolean;
		private var _popoutLayoutProxy:ProxyLayoutSubject;
		private var _relativeLayout:RelativeLayout = new RelativeLayout();
		private var _relativeLayoutInfo:RelativeLayoutInfo = new RelativeLayoutInfo();
		private var _removeCall:DelayedCall;
		
		public function PopoutDisplay(){
			super();
			_relativeLayoutInfo.keepWithinStageBounds = true;
		}
		protected function doRemove():void{
			TopLayerManager.remove(_popout.asset);
			_removeCall = null;
			_added = false;
		}
		protected function onAssetChanged(from:ILayoutView, oldAsset:IDisplayAsset):void{
			if(_added){
				if(oldAsset)TopLayerManager.remove(oldAsset);
				if(_popout.asset)TopLayerManager.add(_popout.asset, _relativeLayout.stage);
			}
		}
	}
}