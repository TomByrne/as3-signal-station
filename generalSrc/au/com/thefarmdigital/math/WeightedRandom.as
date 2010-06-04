package au.com.thefarmdigital.math
{
	import flash.display.Graphics;
	
	public class WeightedRandom
	{
		/**
		 * This generates random numbers (between 0 and 1) that will be more often near a particular
		 * number (0, 1 or anything in between).
		 * 
		 * @param centerPull Increases the likelihood of results appearing near 0.5 (in a bell-curve fashion).
		 * 						Set this to 0 to have no center weighting.
		 * @param centerOffset Adjusts the point that numbers will be closer to. Set this to a negative number
		 * 						to push the weighted point closer to 0, set it to a positive number to push the
		 * 						weighting towards 1. If centerPull is set to 0, either 1 or 0 will be considered
		 * 						the weighted point, increasing the variable then increases the amount of weighting.
		 */
		public static function generate(centerPull:uint=1, centerOffset:int=0):Number{
			var ret:Number = 0;
			for(var i:int=0; i<centerPull+1; ++i){
				var val:Number = Math.random();
				var length:int = Math.abs(centerOffset)+1;
				for(var j:int=1; j<length; ++j){
					val *= Math.random();
				}
				ret += val;
			}
			ret /= (centerPull+1);
			return (centerOffset>0?1-ret:ret);
		}
		/**
		 * Draws a graph of results within a Graphics object. Used for debugging. It is drawn at the size 100x100.
		 */
		public static function graphIn(graphics:Graphics, iterations:Number=10000, centerPull:uint=1, centerOffset:int=0):void{
			var SIZE_W:Number = 100;
			var SIZE_H:Number = 100;
			
			var counts:Array = [];
			var maxCount:Number = 0;
			
			for(var i:int=0; i<iterations; ++i){
				var val:Number = Math.round(generate(centerPull,centerOffset)*SIZE_W);
				if(counts[val]==null){
					counts[val] = 1;
				}else{
					counts[val]++;
				}
				maxCount = Math.max(counts[val],maxCount);
			}
			graphics.lineStyle(0,0);
			graphics.drawRect(0,0,SIZE_W,SIZE_H);
			graphics.moveTo(0,SIZE_H);
			graphics.beginFill(0xffffff);
			var length:int = counts.length;
			for(i=0; i<length; ++i){
				val = counts[i];
				if(isNaN(val))val = 0;
				graphics.lineTo((i/SIZE_W)*SIZE_W,SIZE_H-(val/maxCount)*SIZE_H);
			}
			graphics.lineTo(SIZE_W,SIZE_H);
			graphics.endFill();
		}
	}
}