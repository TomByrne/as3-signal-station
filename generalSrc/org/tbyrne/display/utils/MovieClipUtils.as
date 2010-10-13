package org.tbyrne.display.utils
{
	public class MovieClipUtils
	{
		import flash.display.FrameLabel;
		import flash.display.MovieClip;
		import flash.utils.Dictionary;
		
		import org.tbyrne.core.DelayedCall;
		
		
		private static const delayMap:Dictionary = new Dictionary();
	
	
		/**
		 * Returns the amount of frames in a MovieClip timeline from a specific frame label
		 * until another frame label (or the end of the timeline) is reached.
		 * 
		 * @param movieClip
		 * @param frameLabel
		 * @return the amount of frames after this frame label before another frame label
		 * is reached (or the end of the timeline). If the frame label isn't found -1 is returned.
		 */
		public static function getFrameLabelDuration(movieClip:MovieClip, frameLabel:String):int{
			var labels:Array = movieClip.currentLabels;
			var start:int = getFrameLabelNumber(movieClip,frameLabel);
			var label:FrameLabel;
			if(start!=-1){
				var finish:int = movieClip.totalFrames+1;
				for each(label in labels){
					if(label.frame>start && label.frame<finish){
						finish = label.frame;
					}
				}
				return finish-start;
			}else{
				return -1;
			}
		}
		/**
		 * Returns the frame number of the frame label specified.
		 * 
		 * @param movieClip
		 * @param frameLabel
		 * @return the frame number for the supplied frame label.
		 */
		public static function getFrameLabelNumber(movieClip:MovieClip, frameLabel:String):int{
			var labels:Array = movieClip.currentLabels;
			var label:FrameLabel;
			for each(label in labels){
				if(label.name==frameLabel){
					return label.frame;
				}
			}
			return -1;
		}
	
	
		public static function playFrameLabel(timeline:MovieClip, frameLabel:String):int{
			var duration:int = getFrameLabelDuration(timeline,frameLabel);
			if(duration!=-1){
				var delay:DelayedCall = delayMap[timeline];
				if(delay){
					delay.clear();
					delay = null;
				}
				timeline.gotoAndPlay(frameLabel);
				delay = new DelayedCall(stopTimeline,duration,false,[timeline]);
				delay.begin();
				
				delayMap[timeline] = delay;
			}
			return duration;
		}
		public static function stopTimeline(timeline:MovieClip):void{
			timeline.stop();
			delete delayMap[timeline];
		}
	}
}