package org.farmcode.debug.data.core
{
	import flash.utils.getTimer;
	
	import org.farmcode.display.assets.assetTypes.IStageAsset;

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