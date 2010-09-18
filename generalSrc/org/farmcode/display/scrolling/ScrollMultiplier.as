package org.farmcode.display.scrolling
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	
	public class ScrollMultiplier implements IScrollMetrics
	{
		
		public function get factor():Number{
			return _factor;
		}
		public function set factor(value:Number):void{
			if(_factor!=value){
				_factor = value;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		public function get scrollMatrics():IScrollMetrics{
			return _scrollMetrics;
		}
		public function set scrollMatrics(value:IScrollMetrics):void{
			if(_scrollMetrics!=value){
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.removeHandler(onScrollMetricsChanged);
				}
				_scrollMetrics = value;
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.addHandler(onScrollMetricsChanged);
				}
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scrollMetricsChanged():IAct{
			if(!_scrollMetricsChanged)_scrollMetricsChanged = new Act();
			return _scrollMetricsChanged;
		}
		
		protected var _scrollMetricsChanged:Act;
		private var _scrollMetrics:IScrollMetrics;
		private var _factor:Number;
		
		
		
		public function ScrollMultiplier(factor:Number=1, scrollMatrics:IScrollMetrics=null){
			this.factor = factor;
			this.scrollMatrics = scrollMatrics;
		}
		
		public function get minimum():Number{
			return _scrollMetrics.minimum/factor;
		}
		
		public function get maximum():Number{
			return _scrollMetrics.maximum/factor;
		}
		
		public function get pageSize():Number{
			return _scrollMetrics.pageSize/factor;
		}
		
		public function get scrollValue():Number{
			return _scrollMetrics.scrollValue/factor;
		}
		
		public function set scrollValue(value:Number):void{
			_scrollMetrics.scrollValue = value*_factor;
		}
		
		protected function onScrollMetricsChanged(from:IScrollMetrics):void{
			if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
		}
	}
}