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
			_vScrollMetrics.scrollMetricsChanged.addHandler(onHMetricsChanged);
			
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
			if(_hScrollMetrics.pageSize!=_size.x){
				_hScrollMetrics.pageSize = _size.x;
			}
			if(_vScrollMetrics.pageSize!=_size.y){
				_vScrollMetrics.pageSize = _size.y;
			}
			
			_scrollRect.width = _size.x;
			_scrollRect.height = _size.y;
			checkScrolling();
		}
		override protected function onMeasurementsChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			checkScrolling();
			super.onMeasurementsChanged(from, oldWidth, oldHeight);
		}
		protected function checkScrolling():void{
			var meas:Point = target.measurements;
			if(meas){
				if(_vScrollMetrics.maximum != meas.y){
					_vScrollMetrics.maximum = meas.y;
				}
				if(_hScrollMetrics.maximum != meas.x){
					_hScrollMetrics.maximum = meas.x;
				}
				var targetWidth:Number;
				var targetHeight:Number;
				
				if(_allowHorizontalScroll){
					if(meas.x>_size.x){
						targetWidth = meas.y;
					}else{
						targetWidth = _size.x;
					}
					if(_scrollRect.x != _hScrollMetrics.scrollValue){
						_scrollRect.x = _hScrollMetrics.scrollValue;
					}
				}else{
					targetWidth = _size.x;
					_scrollRect.x = 0;
				}
				
				
				if(_allowVerticalScroll){
					if(meas.y>_size.y){
						targetHeight = meas.y;
					}else{
						targetHeight = _size.y;
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
				setScrollRect(null);
			}
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
			checkScrolling();
		}
		
		private function onHMetricsChanged(from:ScrollMetrics):void{
			checkScrolling();
		}
	}
}