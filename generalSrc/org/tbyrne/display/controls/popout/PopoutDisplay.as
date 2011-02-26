package org.tbyrne.display.controls.popout
{
	import flash.geom.Point;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.DelayedCall;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.IOutroView;
	import org.tbyrne.display.layout.ProxyLayoutSubject;
	import org.tbyrne.display.layout.relative.RelativeLayout;
	import org.tbyrne.display.layout.relative.RelativeLayoutInfo;
	import org.tbyrne.display.utils.TopLayerManager;
	
	public class PopoutDisplay
	{
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
					if(!_relativeLayout.stage){
						Log.error( "PopoutDisplay.popoutShown: No reference to the stage found");
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
		
		public function get relativeTo():ILayoutView{
			return _relativeTo;
		}
		public function set relativeTo(value:ILayoutView):void{
			if(_relativeTo !=value){
				if(_relativeTo){
					_relativeTo.sizeChanged.removeHandler(onRelativePositionChanged);
					_relativeTo.positionChanged.removeHandler(onRelativePositionChanged);
					_relativeTo.assetChanged.removeHandler(onRelativeAssetChanged);
				}
				_relativeTo = value;
				_relativeLayout.scopeView = value;
				if(_relativeTo){
					_relativeTo.sizeChanged.addHandler(onRelativePositionChanged);
					_relativeTo.positionChanged.addHandler(onRelativePositionChanged);
					_relativeTo.assetChanged.addHandler(onRelativeAssetChanged);
					_relativeLayoutInfo.relativeTo = value.asset;
					if(_popout)assessRelativePos();
				}else{
					_relativeLayoutInfo.relativeTo = null;
				}
			}
		}
		
		public function get popout():ILayoutView{
			return _popout;
		}
		public function set popout(value:ILayoutView):void{
			if(_popout!=value){
				if(_popout){
					_popout.assetChanged.removeHandler(onAssetChanged);
					_popout.measurementsChanged.removeHandler(onPopoutMeasChanged);
				}
				var wasShown:Boolean = _popoutShown;
				popoutShown = false;
				_popout = value;
				_outroPopout = (value as IOutroView);
				popoutShown = wasShown;
				if(_popout){
					_popout.assetChanged.addHandler(onAssetChanged);
					_popout.measurementsChanged.addHandler(onPopoutMeasChanged);
					if(_relativeTo)assessRelativePos();
				}
			}
		}
		
		public function get popoutAnchor():String{
			return _popoutAnchor;
		}
		public function set popoutAnchor(value:String):void{
			if(_popoutAnchor!=value){
				_popoutAnchor = value;
				if(_relativeTo && _popout)assessRelativePos();
			}
		}
		
		/**
		 * When set to true enforceMinimums ensures that if the popout is drawn above or below
		 * the relativeView, then it will have a minimum width of the relativeView's width.
		 * If the popout is drawn to the left or right of the relativeView, then the popout
		 * will have a minimum height of the relativeView's height.
		 */
		public function get enforceMinimums():Boolean{
			return _enforceMinimums;
		}
		public function set enforceMinimums(value:Boolean):void{
			if(_enforceMinimums!=value){
				_enforceMinimums = value;
				if(_relativeTo && _popout)assessRelativePos();
			}
		}
		
		/**
		 * When set to true, as is default, lodgeCorners changes the alignment for side anchoring.
		 * For example, if the anchor is set to bottom-right:</br>
		 * - With lodgeCorners set to true, the top-left corner of the popout will touch the top-right
		 * corner of the relativeView.</br>
		 * - With lodgeCorners set to false, the top-left corner of the popout will touch the bottom-right
		 * corner of the relativeView.
		 */
		public function get lodgeCorners():Boolean{
			return _lodgeCorners;
		}
		public function set lodgeCorners(value:Boolean):void{
			if(_lodgeCorners!=value){
				_lodgeCorners = value;
				if(_relativeTo && _popout)assessRelativePos();
			}
		}
		
		public function get popoutLayoutInfo():RelativeLayoutInfo{
			return _relativeLayoutInfo;
		}
		public function get popoutLayout():RelativeLayout{
			return _relativeLayout;
		}
		
		
		
		protected var _popoutClose:Act;
		protected var _popoutOpen:Act;
		
		private var _added:Boolean;
		private var _popout:ILayoutView;
		private var _outroPopout:IOutroView;
		private var _popoutShown:Boolean;
		private var _popoutLayoutProxy:ProxyLayoutSubject;
		private var _relativeLayout:RelativeLayout;
		private var _relativeLayoutInfo:RelativeLayoutInfo = new RelativeLayoutInfo();
		private var _removeCall:DelayedCall;
		private var _relativeTo:ILayoutView;
		private var _popoutAnchor:String = Anchor.BOTTOM;
		private var _enforceMinimums:Boolean = true;
		private var _lodgeCorners:Boolean = true;
		
		public function PopoutDisplay(){
			super();
			_relativeLayout = new RelativeLayout();
			_relativeLayoutInfo.keepWithinStageBounds = true;
		}
		protected function doRemove():void{
			TopLayerManager.remove(_popout.asset);
			_removeCall = null;
			_added = false;
		}
		protected function onAssetChanged(from:ILayoutView, oldAsset:IDisplayObject):void{
			if(_added){
				if(oldAsset)TopLayerManager.remove(oldAsset);
				if(_popout.asset)TopLayerManager.add(_popout.asset, _relativeLayout.stage);
			}
		}
		protected function onRelativeAssetChanged(from:ILayoutView, oldAsset:IDisplayObject):void{
			_relativeLayoutInfo.relativeTo = from.asset;
			_relativeLayout.update();
		}
		protected function onRelativePositionChanged(... params):void{
			if(_popout)assessRelativePos();
		}
		protected function onPopoutMeasChanged(from:ILayoutView, oldWidth:Number, oldHeight:Number):void{
			if(_relativeTo)assessRelativePos();
		}
		protected function assessRelativePos():void{
			var relPos:Point = _relativeTo.position;
			var size:Point = _relativeTo.size;
			var popMeas:Point = _popout.measurements;
			var popMeasWidth:Number = popMeas.x;
			var popMeasHeight:Number = popMeas.y;
			
			if(_enforceMinimums){
				if(_popoutAnchor==Anchor.TOP || _popoutAnchor==Anchor.BOTTOM){
					_relativeLayoutInfo.minWidth = size.x;
					if(popMeasWidth<size.x){
						popMeasWidth = size.x;
					}
					_relativeLayoutInfo.minHeight = NaN;
				}else{
					if(_lodgeCorners || _popoutAnchor==Anchor.LEFT || _popoutAnchor==Anchor.RIGHT){
						_relativeLayoutInfo.minHeight = size.y;
						if(popMeasHeight<size.y){
							popMeasHeight = size.y;
						}
					}else{
						_relativeLayoutInfo.minHeight = NaN;
					}
					_relativeLayoutInfo.minWidth = NaN;
				}
			}else{
				_relativeLayoutInfo.minHeight = NaN;
				_relativeLayoutInfo.minWidth = NaN;
			}
			
			var x:Number;
			var y:Number;
			switch(_popoutAnchor){
				case Anchor.TOP:
					y = -popMeasHeight;
					break;
				case Anchor.TOP_LEFT:
				case Anchor.TOP_RIGHT:
					if(_lodgeCorners){
						y = size.y-popMeasHeight;
					}else{
						y = -popMeasHeight;
					}
					break;
				case Anchor.BOTTOM:
					y = size.y;
					break;
				case Anchor.BOTTOM_LEFT:
				case Anchor.BOTTOM_RIGHT:
					if(_lodgeCorners){
						y = 0;
					}else{
						y = size.y;
					}
					break;
				default:
					y = (size.y-popMeasHeight)/2;
			}
			switch(_popoutAnchor){
				case Anchor.LEFT:
				case Anchor.TOP_LEFT:
				case Anchor.BOTTOM_LEFT:
					x = -popMeasWidth;
					break;
				case Anchor.RIGHT:
				case Anchor.TOP_RIGHT:
				case Anchor.BOTTOM_RIGHT:
					x = size.x;
					break;
				default:
					x = (size.x-popMeasWidth)/2;
			}
			
			_relativeLayoutInfo.relativeOffsetX = x;
			_relativeLayoutInfo.relativeOffsetY = y;
			_relativeLayout.update();
		}
	}
}