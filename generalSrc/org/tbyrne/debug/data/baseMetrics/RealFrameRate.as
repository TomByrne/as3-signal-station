package org.tbyrne.debug.data.baseMetrics
{
	import flash.utils.getTimer;
	
	import org.tbyrne.display.assets.assetTypes.IStageAsset;
	import org.tbyrne.debug.data.core.NumberMonitor;

	public class RealFrameRate extends NumberMonitor
	{
		protected var frames:Array = [];
		
		public function RealFrameRate(){
			super(this,"realFrameRate");
		}
		public function get realFrameRate():int{
			return frames.length;
		}
		override protected function onEnterFrame():void{
			super.onEnterFrame();
			var time:int = getTimer();
			var timePast:int = time<1000?0:time-1000;
			while(frames[0]<timePast){
				frames.shift();
			}
			frames.push(time);
		}
	}
}