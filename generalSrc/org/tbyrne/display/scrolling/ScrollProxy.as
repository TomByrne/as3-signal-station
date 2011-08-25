package org.tbyrne.display.scrolling
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	
	public class ScrollProxy implements IScrollMetrics
	{
		/**
		 * @inheritDoc
		 */
		public function get scrollMetricsChanged():IAct{
			return ((_scrollMetricsChanged) || (_scrollMetricsChanged = new Act()));
		}
		
		protected var _scrollMetricsChanged:Act;
		
		
		
		public function get target():IScrollMetrics{
			return _target;
		}
		public function set target(value:IScrollMetrics):void{
			if(_target!=value){
				if(_target){
					_target.scrollMetricsChanged.removeHandler(onInnerScrollMetricsChanged);
				}
				_target = value;
				if(_target){
					_target.scrollMetricsChanged.addHandler(onInnerScrollMetricsChanged);
				}
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		
		protected var _target:IScrollMetrics;
		
		
		public function ScrollProxy(target:IScrollMetrics=null){
			this.target = target;
		}
		
		public function get minimum():Number{
			return _target?_target.minimum:NaN;
		}
		
		public function get maximum():Number{
			return _target?_target.maximum:NaN;
		}
		
		public function get pageSize():Number{
			return _target?_target.pageSize:NaN;
		}
		
		public function get scrollValue():Number{
			return _target?_target.scrollValue:NaN;
		}
		
		public function set scrollValue(value:Number):void{
			if(_target){
				_target.scrollValue = value;
			}
		}
		
		
		protected function onInnerScrollMetricsChanged(from:IScrollMetrics):void{
			if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
		}
	}
}