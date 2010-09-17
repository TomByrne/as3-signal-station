package org.farmcode.display.containers
{
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.ProxyLayoutSubject;
	import org.farmcode.display.scrolling.IScrollMetrics;
	import org.farmcode.display.scrolling.IScrollable;
	import org.farmcode.display.scrolling.ScrollMetrics;
	
	public class ScrollWrapper extends ProxyLayoutSubject implements IScrollable
	{
		override public function set target(value:ILayoutSubject):void{
			if(super.target!=value){
				if(_targetAsset){
					_targetAsset.mouseWheel.removeHandler(onMouseWheel);
					_targetAsset.scrollRect = null;
				}
				super.target = value;
				_targetView = (value as IView);
				_targetAsset = (_targetView.asset as IInteractiveObjectAsset);
				if(_targetAsset){
					_targetAsset.mouseWheel.addHandler(onMouseWheel);
				}
				checkScrolling(true);
				checkMeasurements();
			}
		}
		
		public function get allowVerticalScroll():Boolean{
			return _allowVerticalScroll;
		}
		public function set allowVerticalScroll(value:Boolean):void{
			if(_allowVerticalScroll!=value){
				_allowVerticalScroll = value;
				checkScrolling(true);
			}
		}
		
		public function get allowHorizontalScroll():Boolean{
			return _allowHorizontalScroll;
		}
		public function set allowHorizontalScroll(value:Boolean):void{
			if(_allowHorizontalScroll!=value){
				_allowHorizontalScroll = value;
				checkScrolling(true);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		/*public function get scrollMetricsChanged():IAct{
			if(!_scrollMetricsChanged)_scrollMetricsChanged = new Act();
			return _scrollMetricsChanged;
		}*/
		
		/**
		 * @inheritDoc
		 */
		public function get mouseWheel():IAct{
			if(!_mouseWheel)_mouseWheel = new Act();
			return _mouseWheel;
		}
		
		protected var _mouseWheel:Act;
		//protected var _scrollMetricsChanged:Act;
		
		private var _allowHorizontalScroll:Boolean = true;
		private var _allowVerticalScroll:Boolean = true;
		private var _target:ILayoutSubject;
		private var _targetView:IView;
		private var _targetAsset:IInteractiveObjectAsset;
		private var _vScrollMetrics:ScrollMetrics = new ScrollMetrics(0,0,0);
		private var _hScrollMetrics:ScrollMetrics = new ScrollMetrics(0,0,0);
		private var _scrollRect:Rectangle = new Rectangle();
		private var _horizontalMultiplier:Number = 1;
		private var _verticalMultiplier:Number = 1;
		
		public function ScrollWrapper(target:ILayoutSubject=null){
			this.target = target;
			_vScrollMetrics.scrollValue = 0;
			_hScrollMetrics.scrollValue = 0;
		}
		
		/*public function addScrollWheelListener(direction:String):Boolean{
			return true;
		}
		public function setScrollMultiplier(direction:String, multiplier:Number):void{
			if(direction==Direction.HORIZONTAL){
				_horizontalMultiplier = multiplier;
			}else{
				_verticalMultiplier = multiplier;
			}
		}
		public function getScrollMultiplier(direction:String):Number{
			if(direction==Direction.HORIZONTAL){
				return _horizontalMultiplier;
			}else{
				return _verticalMultiplier;
			}
		}*/
		public function getScrollMetrics(direction:String):IScrollMetrics{
			if(direction==Direction.VERTICAL){
				return _vScrollMetrics;
			}else{
				return _hScrollMetrics;
			}
		}
		/*public function setScrollMetrics(direction:String,metrics:IScrollMetrics):void{
			var dest:ScrollMetrics;
			if(direction==Direction.VERTICAL){
				dest = _vScrollMetrics;
			}else{
				dest = _hScrollMetrics;
			}
			dest.maximum = metrics.maximum;
			dest.minimum = metrics.minimum;
			dest.pageSize = metrics.pageSize;
			dest.scrollValue = metrics.scrollValue;
			_scrollRect.y = _vScrollMetrics.scrollValue;
			_scrollRect.x = _hScrollMetrics.scrollValue;
			checkScrolling(false);
		}*/
		override public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			_displayPosition.x = x;
			_displayPosition.y = y;
			_displayPosition.width = width;
			_displayPosition.height = height;
			
			if(_vScrollMetrics.pageSize!=height){
				_vScrollMetrics.pageSize = height;
				//_scrollMetricsChanged.perform(this,Direction.VERTICAL,_vScrollMetrics);
			}
			if(_hScrollMetrics.pageSize!=width){
				_hScrollMetrics.pageSize = width;
				//_scrollMetricsChanged.perform(this,Direction.HORIZONTAL,_hScrollMetrics);
			}
			
			_scrollRect.width = width;
			_scrollRect.height = height;
			checkScrolling(true);
		}
		override protected function onMeasurementsChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			checkScrolling(true);
			super.onMeasurementsChanged(from, oldWidth, oldHeight);
		}
		protected function checkScrolling(performAct:Boolean):void{
			var meas:Point = target.measurements;
			var vChange:Boolean;
			var hChange:Boolean;
			if(meas){
				if(_vScrollMetrics.maximum != meas.y){
					_vScrollMetrics.maximum = meas.y;
					vChange = true;
				}
				if(_hScrollMetrics.maximum != meas.x){
					_hScrollMetrics.maximum = meas.x;
					hChange = true;
				}
				if(_displayPosition.width<meas.x || _displayPosition.height<meas.y){
					setScrollRect(_scrollRect);
				}else{
					setScrollRect(null);
				}
				var targetWidth:Number;
				var targetHeight:Number;
				if(_allowHorizontalScroll && meas.x>_displayPosition.width){
					targetWidth = meas.x;
				}else{
					targetWidth = _displayPosition.width;
				}
				if(_allowVerticalScroll && meas.y>_displayPosition.height){
					targetHeight = meas.y;
				}else{
					targetHeight = _displayPosition.height;
				}
				target.setDisplayPosition(0,0,targetWidth,targetHeight);
			}else{
				hChange = vChange = true;
				setScrollRect(null);
			}
			/*if(performAct && _scrollMetricsChanged){
				if(vChange){
					_scrollMetricsChanged.perform(this,Direction.VERTICAL,_vScrollMetrics);
				}
				if(hChange){
					_scrollMetricsChanged.perform(this,Direction.HORIZONTAL,_hScrollMetrics);
				}
			}*/
		}
		protected function setScrollRect(rect:Rectangle):void{
			if(_targetView){
				_targetAsset.setPosition(_displayPosition.x,_displayPosition.y);
				_targetAsset.scrollRect = rect;
			}
		}
		protected function onMouseWheel(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo, delta:int):void{
			if(_mouseWheel)_mouseWheel.perform(this,delta);
		}
	}
}