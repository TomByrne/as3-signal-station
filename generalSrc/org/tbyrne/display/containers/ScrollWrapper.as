package org.tbyrne.display.containers
{
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.binding.PropertyWatcher;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.ProxyLayoutSubject;
	import org.tbyrne.display.scrolling.IScrollMetrics;
	import org.tbyrne.display.scrolling.IScrollable;
	import org.tbyrne.display.scrolling.ScrollMetrics;
	
	public class ScrollWrapper extends ProxyLayoutSubject implements IScrollable
	{
		override public function set target(value:ILayoutSubject):void{
			if(super.target!=value){
				super.target = value;
				_targetView = (value as IView);
				_assetBinding.bindable = _targetView;
			}
		}
		
		public function get allowVerticalScroll():Boolean{
			return _allowVerticalScroll;
		}
		public function set allowVerticalScroll(value:Boolean):void{
			if(_allowVerticalScroll!=value){
				_allowVerticalScroll = value;
				checkScrolling();
			}
		}
		
		public function get allowHorizontalScroll():Boolean{
			return _allowHorizontalScroll;
		}
		public function set allowHorizontalScroll(value:Boolean):void{
			if(_allowHorizontalScroll!=value){
				_allowHorizontalScroll = value;
				checkScrolling();
			}
		}
		
		private var _ignoreMetricsChanges:Boolean;
		private var _allowHorizontalScroll:Boolean = true;
		private var _allowVerticalScroll:Boolean = true;
		private var _target:ILayoutSubject;
		private var _targetView:IView;
		private var _targetAsset:IInteractiveObject;
		private var _vScrollMetrics:ScrollMetrics = new ScrollMetrics(0,0,0);
		private var _hScrollMetrics:ScrollMetrics = new ScrollMetrics(0,0,0);
		private var _scrollRect:Rectangle = new Rectangle();
		
		private var _assetBinding:PropertyWatcher;
		
		public function ScrollWrapper(target:ILayoutSubject=null){
			_assetBinding = new PropertyWatcher("asset",null, changeAsset);
			this.target = target;
			
			_vScrollMetrics.scrollValue = 0;
			_vScrollMetrics.scrollMetricsChanged.addHandler(onVMetricsChanged);
			
			_hScrollMetrics.scrollValue = 0;
			_hScrollMetrics.scrollMetricsChanged.addHandler(onHMetricsChanged);
			
		}
		
		
		public function getScrollMetrics(direction:String):IScrollMetrics{
			if(direction==Direction.VERTICAL){
				return _vScrollMetrics;
			}else{
				return _hScrollMetrics;
			}
		}
		override protected function validatePosition():void{
			_targetAsset.setPosition(_position.x,_position.y);
		}
		override protected function validateSize():void{
			_ignoreMetricsChanges = true;
			if(_hScrollMetrics.pageSize!=_size.x){
				_hScrollMetrics.pageSize = _size.x;
			}
			if(_vScrollMetrics.pageSize!=_size.y){
				_vScrollMetrics.pageSize = _size.y;
			}
			_ignoreMetricsChanges = false;
			
			_scrollRect.width = _size.x;
			_scrollRect.height = _size.y;
			checkScrolling();
		}
		override protected function onMeasurementsChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			checkScrolling();
			super.onMeasurementsChanged(from, oldWidth, oldHeight);
		}
		protected function checkScrolling():void{
			_ignoreMetricsChanges = true;
			if(target){
				var meas:Point = target.measurements;
				if(meas){
					var targetHeight:Number = Math.max(meas.y,_size.y);
					if(_vScrollMetrics.maximum != targetHeight){
						_vScrollMetrics.maximum = targetHeight;
					}
					var targetWidth:Number = Math.max(meas.x,_size.x);
					if(_hScrollMetrics.maximum != targetWidth){
						_hScrollMetrics.maximum = targetWidth;
					}
					
					if(_allowHorizontalScroll){
						targetWidth = targetWidth;
						if(_hScrollMetrics.scrollValue>_hScrollMetrics.maximum-_hScrollMetrics.pageSize){
							_hScrollMetrics.scrollValue = _hScrollMetrics.maximum-_hScrollMetrics.pageSize;
						}
						if(_scrollRect.x != _hScrollMetrics.scrollValue){
							_scrollRect.x = _hScrollMetrics.scrollValue;
						}
					}else{
						targetWidth = _size.x;
						_scrollRect.x = 0;
					}
					
					
					if(_allowVerticalScroll){
						targetHeight = targetHeight;
						if(_vScrollMetrics.scrollValue>_vScrollMetrics.maximum-_vScrollMetrics.pageSize){
							_vScrollMetrics.scrollValue = _vScrollMetrics.maximum-_vScrollMetrics.pageSize;
						}
						if(_scrollRect.y != _vScrollMetrics.scrollValue){
							_scrollRect.y = _vScrollMetrics.scrollValue;
						}
					}else{
						targetHeight = _size.y;
						_scrollRect.y = 0;
					}
					
					
					if(_size.x<meas.x || _size.y<meas.y){
						setScrollRect(_scrollRect);
					}else{
						setScrollRect(null);
					}
					target.setSize(targetWidth,targetHeight);
				}else{
					_hScrollMetrics.scrollValue = 0;
					_vScrollMetrics.scrollValue = 0;
					_hScrollMetrics.maximum = _size.x;
					_vScrollMetrics.maximum = _size.y;
					target.setSize(_size.x,_size.y);
					setScrollRect(null);
				}
			}
			_ignoreMetricsChanges = false;
		}
		protected function changeAsset(oldValue:IDisplayObject, newValue:IDisplayObject):void{
			if(_targetAsset){
				_targetAsset.scrollRect = null;
			}
			_targetAsset = (newValue as IInteractiveObject);
			checkScrolling();
		}
		protected function setScrollRect(rect:Rectangle):void{
			if(_targetAsset){
				_targetAsset.scrollRect = rect;
			}
		}
		private function onVMetricsChanged(from:ScrollMetrics):void{
			if(!_ignoreMetricsChanges)checkScrolling();
		}
		
		private function onHMetricsChanged(from:ScrollMetrics):void{
			if(!_ignoreMetricsChanges)checkScrolling();
		}
	}
}