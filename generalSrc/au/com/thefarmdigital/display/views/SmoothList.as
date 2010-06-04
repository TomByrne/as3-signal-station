package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.farmcode.display.constants.Direction;
	
	/**
	 * SmoothList adds smooth scrolling (as opposed to line-by-line scrolling to a List)
	 */
	
	public class SmoothList extends List
	{
		override public function set dataProvider(value:Array):void{
			scrollFract = 0;
			super.dataProvider = value;
		}
		override public function getScrollMetrics(direction:String):ScrollMetrics{
			ensureMeasurements();
			if(direction==this.direction){
				validate();
				var pageSize:Number = direction==Direction.VERTICAL?height-_topPadding-_bottomPadding:width-_leftPadding-_rightPadding;
				var ret:ScrollMetrics = new ScrollMetrics(0,_measuredListSize,pageSize);
				
				var measurement:Point = _measurements[_scrollIndex];
				var next:Point = _measurements[_scrollIndex+1];
				if(measurement){
					ret.value = measurement.x+(next?((next.x-measurement.x)*scrollFract):0);
				}else{
					ret.value = 0;
				}
				return ret;
			}else{
				return super.getScrollMetrics(direction);
			}
		}
		override public function setScrollMetrics(direction:String,metrics:ScrollMetrics):void{
			ensureMeasurements();
			if(direction==this.direction){
				if(_measurements.length){
					var i:int=0;
					while(i+1<_measurements.length && _measurements[i+1].x<metrics.value){
						i++;
					}
					var measurement:Point = _measurements[i];
					var next:Point = _measurements[i+1];
					_scrollIndex = i;
					scrollFract = (measurement && next)?Math.min(Math.max((metrics.value-measurement.x)/(next.x-measurement.x),0),1):0;
				}else{
					_scrollIndex = 0;
					scrollFract = 0;
				}
				invalidate();
			}else{
				super.setScrollMetrics(direction,metrics);
			}
		}
		
		/*
			The scrolling works by converting the pixel value that the scrollbars work with to
			and index/fract pair, which is then used internally with renderers.
		*/
		protected var scrollFract:Number = 0; // 0 - 1 (tied to scrollIndex)
		
		
		public function SmoothList(){
			super();
		}
		override protected function draw():void{
			if(_measurements){
				var measurement:Point = _measurements[_scrollIndex];
				var next:Point = _measurements[_scrollIndex+1];
				var offset:Number = (measurement && next?-scrollFract*(next.x-measurement.x):0);
				if(direction==Direction.VERTICAL){
					_containerPos.y = offset;
				}else{
					_containerPos.x = offset;
				}
			}
			super.draw();
		}
		override protected function getMaxRenderers(protoSeparator:DisplayObject):int{
			return super.getMaxRenderers(protoSeparator)+1;
		}
	}
}