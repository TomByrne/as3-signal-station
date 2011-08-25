package org.tbyrne.display.scrolling
{
	
	public class ScrollRounder extends ScrollProxy
	{
		
		public var roundTo:Number;
		
		
		public function ScrollRounder(target:IScrollMetrics=null, roundTo:Number=NaN){
			super(target);
			this.roundTo = roundTo;
		}
		
		override public function set scrollValue(value:Number):void{
			if(_target){
				if(!isNaN(roundTo)){
					var roundValue:Number = round(value/roundTo)*roundTo;
					
					var absRoundDif:Number = value-roundValue;
					if(absRoundDif<0)absRoundDif = -absRoundDif;
					
					var endDif:Number = (maximum-pageSize-value);
					if(endDif<0)endDif = -endDif;
					
					if(endDif<absRoundDif){
						_target.scrollValue = maximum-pageSize;
					}else{
						_target.scrollValue = roundValue;
					}
				}else{
					_target.scrollValue = value;
				}
			}
		}
		private function round(value:Number): int{
			return value%1 ? (value>0?int(value+0.5) : int(value-0.5)) :value;
		}
	}
}