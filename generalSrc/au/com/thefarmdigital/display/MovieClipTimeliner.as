package au.com.thefarmdigital.display
{
	import au.com.thefarmdigital.display.events.MovieClipTimelinerEvent;
	
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.farmcode.core.DelayedCall;
	
	[Event(name="playbackFinish", type="au.com.thefarmdigital.display.events.MovieClipTimelinerEvent")]
	public class MovieClipTimeliner extends EventDispatcher
	{
		public function get movieClip():MovieClip{
			return _movieClip;
		}
		public function set movieClip(value:MovieClip):void{
			if(_movieClip != value){
				_movieClip = value;
				analyseFrames();
			}
		}
		public function get currentRun():String{
			return _currentRun?_currentRun.frameRun.name:null;
		}
		public function get framesTillStop():uint{
			var frames:uint = 0;
			if(_currentRun){
				if(!_currentRun.play){
					return 0;
				}else if(!_currentRun.reverse){
					frames = _currentRun.frameRun.length-(_currentRun.frameRun.startFrame-_movieClip.currentFrame);
				}else{
					frames = (_currentRun.frameRun.startFrame-_movieClip.currentFrame);
				}
			}
			for each(var pending:PendingRun in _pending){
				if(pending.play){
					frames += pending.frameRun.length;
				}else{
					frames++;
					return frames;
				}
			}
			return frames;
		}
		
		public var defaultFrameRun:String;
		
		private var _movieClip:MovieClip;
		private var _frameRuns:Dictionary;
		private var _frameReflections:Dictionary;
		private var _pending:Array = [];
		private var _currentRun:PendingRun;
		private var _nextCall:DelayedCall = new DelayedCall(playNext,0,false);
		
		public function MovieClipTimeliner(movieClip:MovieClip=null){
			this.movieClip = movieClip;
		}
		
		/**
		 * This is generally used when one frame run is the reverse animation of another, it means that
		 * when switching halfway through one to the other it should seemlessly revert.
		 */
		public function setFrameRunReflection(frameRun1:String, frameRun2:String, bothWays:Boolean=false):void{
			var reflections:Array = _frameReflections[frameRun1];
			if(!reflections){
				reflections = _frameReflections[frameRun1] = [];
			}
			reflections.push(frameRun2);
			if(bothWays){
				setFrameRunReflection(frameRun2, frameRun1, false);
			}
		}
		public function showPlayFrameRun(frameRun:String, stack:Boolean=false, reverse:Boolean=false):void{
			showFrameRun(frameRun,stack,reverse,true);
		}
		public function showPlayDefaultFrameRun(stack: Boolean = false, reverse:Boolean=false): void {
			this.showPlayFrameRun(this.defaultFrameRun, stack, reverse);
		}
		public function showStopFrameRun(frameRun:String, stack:Boolean=false):void{
			showFrameRun(frameRun,stack,false,false);
		}
		public function showStopDefaultFrameRun(stack: Boolean = false): void {
			this.showStopFrameRun(this.defaultFrameRun, stack);
		}
		protected function showFrameRun(frameRun:String, stack:Boolean, reverse:Boolean, play:Boolean):void{
			if(_frameRuns){
				var run:FrameRun = _frameRuns[frameRun];
				if(run){
					var pendingRun:PendingRun = new PendingRun(run,play,reverse);
					if(stack && _currentRun && _currentRun.play){
						_pending.push(pendingRun);
					}else{
						_pending = [];
						playRun(pendingRun);
					}
				}else{
					throw new Error("Can't find frame run: "+frameRun);
				}
			}
		}
		
		protected function playNext():void{
			movieClip.removeEventListener(Event.ENTER_FRAME, reverseFrame);
			var next:PendingRun = _pending.shift();
			if(next){
				playRun(next);
			}else if(defaultFrameRun){
				showStopDefaultFrameRun();
			}else{
				movieClip.stop();
			}
			
			if (!next || !next.play)
			{
				this.dispatchEvent(new MovieClipTimelinerEvent(MovieClipTimelinerEvent.PLAYBACK_FINISH));
			}
		}
		protected function playRun(run:PendingRun):void{
			_nextCall.clear();
			movieClip.removeEventListener(Event.ENTER_FRAME, reverseFrame);
			var lastRun:FrameRun = _currentRun?_currentRun.frameRun:null;
			_currentRun = run;
			var start:uint = _currentRun.frameRun.startFrame;
			if(_currentRun.play){
				var duration:int = _currentRun.frameRun.length;
				if(lastRun && isReflection(_currentRun.frameRun,lastRun)){
					var progress:Number = (movieClip.currentFrame-lastRun.startFrame)/lastRun.length;
					start += int((1-progress)*duration);
					duration -= int((1-progress)*duration);
				}
				if(_currentRun.reverse){
					movieClip.gotoAndStop(start);
					movieClip.addEventListener(Event.ENTER_FRAME, reverseFrame);
				}else{
					movieClip.gotoAndPlay(start);
				}
				_nextCall.startDelay = duration;
				_nextCall.begin();
			}else{
				movieClip.gotoAndStop(start);
			}
		}
		protected function isReflection(run:FrameRun, reflectionRun:FrameRun):Boolean{
			var reflection:Array = _frameReflections[run.name];
			if(reflection){
				return reflection.indexOf(reflectionRun.name)!=-1;
			}
			return false;
		}
		protected function reverseFrame(e:Event):void{
			movieClip.gotoAndStop(movieClip.currentFrame-1);
		}
		protected function analyseFrames():void{
			_frameReflections = new Dictionary();
			var frameRuns:Array = [];
			for each(var label:FrameLabel in movieClip.currentLabels){
				frameRuns.push(new FrameRun(label.name, label.frame));
			}
			frameRuns.sort(sortRuns);
			if(!frameRuns.length || (frameRuns[0] as FrameRun).startFrame!=0){
				frameRuns.unshift(new FrameRun("",1));
			}
			_frameRuns = new Dictionary();
			var lastRun:FrameRun;
			for each(var run:FrameRun in frameRuns){
				if(lastRun){
					lastRun.length = run.startFrame-lastRun.startFrame;
				}
				lastRun = run;
				_frameRuns[run.name] = run;
			}
			lastRun.length = movieClip.totalFrames-lastRun.startFrame+1;
		}
		protected function sortRuns(run1:FrameRun, run2:FrameRun):int{
			if(run1.startFrame<run2.startFrame){
				return -1;
			}else if(run1.startFrame>run2.startFrame){
				return 1;
			}else{
				return 0;
			}
		}
	}
}
import flash.display.FrameLabel;
	
class FrameRun{
	public var name:String;
	public var startFrame:uint;
	public var length:uint;
	public var reflection:FrameRun;
	
	public function FrameRun(name:String, startFrame:uint){
		this.name = name;
		this.startFrame = startFrame;
	}
}
class PendingRun{
	public var frameRun:FrameRun;
	public var play:Boolean;
	public var reverse:Boolean;
	
	public function PendingRun(frameRun:FrameRun, play:Boolean, reverse:Boolean){
		this.frameRun = frameRun;
		this.play = play;
		this.reverse = reverse;
	}
}