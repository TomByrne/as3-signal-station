package org.tbyrne.queueing.queueItems.display
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.DelayedCall;
	import org.tbyrne.queueing.IQueueItem;

	public class AnimationQI implements IQueueItem
	{
		public function get totalSteps():uint{
			return 1;
		}
		public function get stepFinished():IAct{
			return _stepFinished;
		}
		
		public var movieClip:MovieClip;
		public var startFrame:int; // 0 is the first frame, positive numbers count from the start, negative numbers from the end
		public var endFrame:int; // 0 is the last frame, positive numbers count from the start, negative numbers from the end
		
		protected var _stepFinished:Act = new Act();
		
		public function AnimationQI(movieClip:MovieClip=null, startFrame:int=0, endFrame:int=0){
			this.movieClip = movieClip;
			this.startFrame = startFrame;
			this.endFrame = endFrame;
		}
		
		public function step(currentStep:uint):void{
			var startFrame:int = getFrameNumber(this.startFrame,true);
			var endFrame:int = getFrameNumber(this.endFrame,true);
			
			movieClip.gotoAndPlay(startFrame);
			var delayedCall:DelayedCall = new DelayedCall(onComplete,endFrame-startFrame,false);
		}
		protected function onComplete(e:Event):void{
			_stepFinished.perform(this);
		}
		protected function getFrameNumber(frame:int, start:Boolean):int{
			if(frame==0){
				return start?0:movieClip.totalFrames;
			}else if(frame<0){
				return movieClip.totalFrames+frame;
			}else{
				return frame;
			}
		}
	}
}