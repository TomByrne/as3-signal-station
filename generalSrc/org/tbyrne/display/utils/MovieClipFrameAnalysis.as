package org.tbyrne.display.utils
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.validation.ValidationFlag;
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	
	public class MovieClipFrameAnalysis implements IPoolable{
		private static const pool:ObjectPool = new ObjectPool(MovieClipFrameAnalysis);
		public static function getNew(movieClip:MovieClip=null):MovieClipFrameAnalysis{
			var ret:MovieClipFrameAnalysis = pool.takeObject();
			ret.movieClip = movieClip;
			return ret;
		}
		
		public function get movieClip():MovieClip{
			return _movieClip;
		}
		public function set movieClip(value:MovieClip):void{
			if(_movieClip!=value){
				_movieClip = value;
				_framesAnalysedFlag.invalidate();
			}
		}
		
		private var _framesAnalysedFlag:ValidationFlag = new ValidationFlag(analyseFrames,false);
		
		private var _movieClip:MovieClip;
		private var _frameRuns:Dictionary;
		
		public function MovieClipFrameAnalysis(movieClip:MovieClip=null){
			this.movieClip = movieClip;
		}
		public function getFrameLabelDuration(frameLabel:String):int{
			_framesAnalysedFlag.validate();
			var run:FrameRun = _frameRuns[frameLabel];
			if(run){
				return run.length;
			}else{
				return -1;
			}
		}
		public function playFrameLabel(frameLabel:String):int{
			_framesAnalysedFlag.validate();
			var run:FrameRun = _frameRuns[frameLabel];
			if(run){
				var end:int = run.startFrame+run.length;
				if(_movieClip.currentFrame>=run.startFrame && _movieClip.currentFrame<end){
					return end-_movieClip.currentFrame;
				}else{
					_movieClip.gotoAndPlay(frameLabel);
					return run.length;
				}
			}else{
				return -1;
			}
		}
		protected function analyseFrames():void{
			if(_movieClip){
				var frameRuns:Array = [];
				for each(var label:FrameLabel in _movieClip.currentLabels){
					frameRuns.push(new FrameRun(label.name, label.frame));
				}
				frameRuns.sort(sortRuns);
				if(!frameRuns.length || (frameRuns[0] as FrameRun).startFrame!=1){
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
				lastRun.length = _movieClip.totalFrames-lastRun.startFrame+1;
			}
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
		public function reset():void{
			_movieClip=null;
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}	
}
class FrameRun{
	public var name:String;
	public var startFrame:uint;
	public var length:uint;
	
	public function FrameRun(name:String, startFrame:uint){
		this.name = name;
		this.startFrame = startFrame;
	}
}