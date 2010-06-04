package org.farmcode.display.behaviour.misc
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.TopLayerManager;
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	import org.farmcode.display.behaviour.ViewBehaviour;
	import org.farmcode.display.layout.ProxyLayoutSubject;
	import org.farmcode.display.layout.relative.RelativeLayout;
	import org.farmcode.display.layout.relative.RelativeLayoutInfo;
	
	public class PopoutDisplay extends ViewBehaviour
	{
		public function get popoutShown():Boolean{
			return _popoutShown;
		}
		public function set popoutShown(value:Boolean):void{
			if(value!=_popoutShown){
				_popoutShown = value;
				if(_popoutShown){
					if(!_popoutLayoutProxy){
						_popoutLayoutProxy = new ProxyLayoutSubject();
						_popoutLayoutProxy.layoutInfo = _relativeLayoutInfo;
					}
					_relativeLayout.addSubject(_popoutLayoutProxy);
					_relativeLayout.stage = asset.stage;
					_popoutLayoutProxy.target = _popout;
					_relativeLayoutInfo.relativeTo = asset;
					TopLayerManager.add(_popout.asset, asset.stage);
					_popoutOpen.perform(this,_popout);
				}else{
					_relativeLayout.removeSubject(_popoutLayoutProxy);
					_popoutLayoutProxy.target = null;
					TopLayerManager.remove(_popout.asset);
					_popoutClose.perform(this,_popout);
				}
			}
		}
		
		public function get popout():ILayoutViewBehaviour{
			return _popout;
		}
		public function set popout(value:ILayoutViewBehaviour):void{
			if(_popout!=value){
				var wasShown:Boolean = _popoutShown;
				popoutShown = false;
				_popout = value;
				popoutShown = wasShown;
			}
		}
		
		
		public function get popoutLayoutInfo():RelativeLayoutInfo{
			return _relativeLayoutInfo;
		}
		public function get popoutLayout():RelativeLayout{
			return _relativeLayout;
		}
		
		public function get popoutOpen():IAct{
			return _popoutOpen;
		}
		public function get popoutClose():IAct{
			return _popoutClose;
		}
		
		private var _relativeOffsetY:Number;
		private var _relativeOffsetX:Number;
		private var _popout:ILayoutViewBehaviour;
		private var _popoutShown:Boolean;
		private var _popoutLayoutProxy:ProxyLayoutSubject;
		private var _relativeLayout:RelativeLayout = new RelativeLayout();
		private var _relativeLayoutInfo:RelativeLayoutInfo = new RelativeLayoutInfo();
		
		private var _popoutOpen:Act = new Act();  // (popoutDisplay:PopoutDisplay, popout:ILayoutViewBehaviour)
		private var _popoutClose:Act = new Act(); // (popoutDisplay:PopoutDisplay, popout:ILayoutViewBehaviour)
		
		public function PopoutDisplay(asset:DisplayObject=null){
			super(asset);
			_relativeLayoutInfo.keepWithinStageBounds = true;
		}
	}
}