package org.farmcode.display.scrolling
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.INumberConsumer;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	/**
	 * A set of scroll instructions
	 */
	public class ScrollMetrics implements IScrollMetrics, INumberConsumer, INumberProvider
	{
		
		/**
		 * @inheritDoc
		 */
		public function get scrollMetricsChanged():IAct{
			if(!_scrollMetricsChanged)_scrollMetricsChanged = new Act();
			return _scrollMetricsChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get numericalValueChanged():IAct{
			if(!_numericalValueChanged)_numericalValueChanged = new Act();
			return _numericalValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			return numericalValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return numericalValueChanged;
		}
		
		
		/** The minimum value in the scroll */
		public function get minimum():Number{
			return _minimum;
		}
		public function set minimum(value:Number):void{
			if(_minimum!=value){
				_minimum = value;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		/** The maximum value in the scroll */
		public function get maximum():Number{
			return _maximum;
		}
		public function set maximum(value:Number):void{
			if(_maximum!=value){
				_maximum = value;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		/** The size of a single page in the scroll */
		public function get pageSize():Number{
			return _pageSize;
		}
		public function set pageSize(value:Number):void{
			if(_pageSize!=value){
				_pageSize = value;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		/** The current scroll value between minimum and maximum */
		public function get scrollValue():Number{
			return _scrollValue;
		}
		public function set scrollValue(value:Number):void{
			if(_scrollValue!=value){
				_scrollValue = value;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
			}
		}
		
		
		public function get numericalValue():Number{
			return scrollValue;
		}
		public function set numericalValue(value:Number):void{
			scrollValue = value;
		}
		public function get stringValue():String{
			return String(scrollValue);
		}
		public function get value():*{
			return scrollValue;
		}
		
		
		protected var _numericalValueChanged:Act;
		protected var _scrollMetricsChanged:Act;
		
		private var _minimum:Number;
		private var _maximum:Number;
		private var _pageSize:Number;
		private var _scrollValue:Number;
		
		/**
		 * Creates a new scroll instruction.
		 * 
		 * @param	minimum		The minimum value of a scroll
		 * @param	maximum		The maximum value of a scroll
		 * @param	pageSize	The size of a page in the scroll area
		 */
		public function ScrollMetrics(minimum:Number=0, maximum:Number=NaN, 
			pageSize:Number=NaN)
		{
			this.minimum = minimum;
			this.maximum = maximum;
			this.pageSize = pageSize;
		}
		public function toString():String{
			return "[ScrollMetrics max:"+maximum+" min:"+minimum+" val:"+scrollValue+" pageSize: "+pageSize+"]";
		}
	}
}