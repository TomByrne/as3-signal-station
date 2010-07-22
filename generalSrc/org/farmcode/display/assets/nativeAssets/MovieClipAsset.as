package org.farmcode.display.assets.nativeAssets {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IMovieClipAsset;
	import org.farmcode.display.assets.states.IStateDef;
	import org.farmcode.display.validation.ValidationFlag;
	
	
	public class MovieClipAsset extends SpriteAsset implements IMovieClipAsset {
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				var assArray:Array;
				if(_movieClip){
					_childClips = new Dictionary(true);
				}
				super.displayObject = value;
				if(value){
					_movieClip = value as MovieClip;
					addChildren(_movieClip);
				}else{
					_movieClip = null;
				}
				_mainAnalysis.movieClip = _movieClip;
			}
		}
		
		private var _movieClip:MovieClip;
		private var _mainAnalysis:MovieClipFrameAnalysis = new MovieClipFrameAnalysis();
		private var _childClips:Dictionary = new Dictionary(true);
		
		public function MovieClipAsset() {
			super();
			addedToStage.addHandler(onAddedToStage);
			added.addHandler(onAdded);
			removed.addHandler(onRemoved);
		}
		override public function addStateList(stateList:Array):void{
			super.addStateList(stateList);
			applyChildStates();
		}
		override public function removeStateList(stateList:Array):void{
			super.removeStateList(stateList);
			applyChildStates();
		}
		override protected function onStateSelChanged(state:IStateDef):void{
			super.onStateSelChanged(state);
			applyChildStates();
		}
		protected function applyChildStates():void{
			for(var i:* in _childClips){
				setAllStateListsIn(_childClips[i]);
			}
		}
		
		override protected function isStateAvailable(state:IStateDef, otherAvailable:Array):Boolean {
			return true;
		}
		override protected function isStateNameAvailable(stateName:String):Boolean{
			return (_mainAnalysis.getFrameLabelDuration(stateName)!=-1);
		}
		override protected function applyState(state:IStateDef, stateName:String, appliedStates:Array):Number{
			var ret:Number = super.applyState(state, stateName, appliedStates);
			if(!appliedStates.length){
				var thisRet:int = _mainAnalysis.playFrameLabel(stateName);
				var stage:Stage = _movieClip.stage;
				if(stage && thisRet!=-1) {
					return(thisRet/stage.frameRate);
				}
				if(thisRet>ret)ret = thisRet;
			}
			return ret;
		}
		protected function onAddedToStage(from:IAsset):void{
			applyAvailableStates();
		}
		protected function onAdded(e:Event, from:IAsset):void{
			var target:MovieClip = (e.target as MovieClip);
			if(target && target!=_movieClip){
				addChild(target);
			}
		}
		protected function onRemoved(e:Event, from:IAsset):void{
			var target:MovieClip = (e.target as MovieClip);
			if(target && target!=_movieClip){
				removeChild(target);
			}
		}
		protected function removeChild(target:MovieClip):void{
			if(_childClips[target]){
				var frameAnalysis:MovieClipFrameAnalysis = _childClips[target];
				frameAnalysis.release();
				delete _childClips[target];
				removeChildren(target);
			}
		}
		protected function removeChildren(parent:MovieClip):void{
			for(var i:int=0; i<parent.numChildren; ++i){
				var child:MovieClip = parent.getChildAt(i) as MovieClip;
				if(child){
					removeChild(child);
				}
			}
		}
		protected function addChild(target:MovieClip):void{
			var asset:IMovieClipAsset = NativeAssetFactory.getExisting(target);
			if(!asset){
				var frameAnalysis:MovieClipFrameAnalysis = MovieClipFrameAnalysis.getNew(target);
				_childClips[target] = frameAnalysis;
				addChildren(target);
				if(stage)setAllStateListsIn(frameAnalysis);
			}
		}
		protected function addChildren(parent:MovieClip):void{
			for(var i:int=0; i<parent.numChildren; ++i){
				var child:MovieClip = parent.getChildAt(i) as MovieClip;
				if(child){
					addChild(child);
				}
			}
		}
		protected function setAllStateListsIn(frameAnalysis:MovieClipFrameAnalysis):void{
			for each(var stateList:Array in _stateLists){
				for each(var state:IStateDef in stateList){
					if(state.selection!=-1){
						var stateName:String = state.options[state.selection];
						var duration:int = frameAnalysis.playFrameLabel(stateName);
						if(duration!=-1){
							var stage:Stage = frameAnalysis.movieClip.stage;
							if(stage) {
								var time:Number = (duration/stage.frameRate);
								if(state.stateChangeDuration<time){
									state.stateChangeDuration = time;
								}
							}
							return;
						}
					}
				}
			}
		}
	}
}
import flash.display.FrameLabel;
import flash.display.MovieClip;
import flash.utils.Dictionary;

import org.farmcode.display.validation.ValidationFlag;
import org.farmcode.hoborg.IPoolable;
import org.farmcode.hoborg.ObjectPool;

class MovieClipFrameAnalysis implements IPoolable{
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
class FrameRun{
	public var name:String;
	public var startFrame:uint;
	public var length:uint;
	
	public function FrameRun(name:String, startFrame:uint){
		this.name = name;
		this.startFrame = startFrame;
	}
}