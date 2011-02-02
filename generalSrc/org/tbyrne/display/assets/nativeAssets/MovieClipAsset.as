package org.tbyrne.display.assets.nativeAssets {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IMovieClip;
	import org.tbyrne.display.assets.states.IStateDef;
	import org.tbyrne.display.utils.MovieClipFrameAnalysis;
	
	
	public class MovieClipAsset extends SpriteAsset implements IMovieClip {
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
		private var _toRemove:Array;
		
		public function MovieClipAsset(factory:NativeAssetFactory=null){
			super(factory);
			added.addHandler(onAdded);
			removed.addHandler(onRemoved);
		}
		override protected function _addStateList(stateList:Array):void{
			super._addStateList(stateList);
			applyChildStates();
		}
		override protected function _removeStateList(stateList:Array):void{
			super._removeStateList(stateList);
			applyChildStates();
		}
		override protected function onStateSelChanged(state:IStateDef):void{
			for each(var stateName:String in state.options){
				if(isStateNameAvailable(stateName)){
					super.onStateSelChanged(state);
					break;
				}
			}
			applyChildStates();
		}
		protected function applyChildStates():void{
			for(var i:* in _childClips){
				setAllStateListsIn(_childClips[i],true);
			}
			if(_toRemove){
				for(var j:int=_toRemove.length-1; j>=0; --j){
					removeChild(_toRemove[j]);
				}
				_toRemove = null;
			}
		}
		
		override protected function isStateAvailable(state:IStateDef, otherAvailable:Array):Boolean {
			return true;
		}
		override protected function isStateNameAvailable(stateName:String):Boolean{
			return (_mainAnalysis.getFrameLabelDuration(stateName)!=-1);
		}
		override protected function prioritiseStates(newStates:Array):Array{
			var positions:Array = [];
			for each(var state:IStateDef in newStates){
				var selection:String = state.options[state.selection];
				var index:int = _mainAnalysis.getFrameLabelIndex(selection);
				positions.push(index);
			}
			var indices:Array = positions.sort(Array.RETURNINDEXEDARRAY);
			positions = []
			for each(var i:int in indices){
				positions.push(newStates[i]);
			}
			return positions;
		}
		override protected function applyState(state:IStateDef, stateName:String, appliedStates:Array):Number{
			var ret:Number = super.applyState(state, stateName, appliedStates);
			if(!appliedStates.length){
				var thisRet:Number = _mainAnalysis.playFrameLabel(stateName);
				var stage:Stage = _movieClip.stage;
				if(stage && thisRet!=-1) {
					thisRet = (thisRet/stage.frameRate);
					if(thisRet>ret)ret = thisRet;
				}
			}
			return ret;
		}
		override protected function onAddedToStage():void{
			super.onAddedToStage();
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
			var asset:IMovieClip = _nativeFactory.getExisting(target);
			if(!asset){
				var frameAnalysis:MovieClipFrameAnalysis = MovieClipFrameAnalysis.getNew(target);
				_childClips[target] = frameAnalysis;
				addChildren(target);
				if(stage)setAllStateListsIn(frameAnalysis,false);
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
		protected function setAllStateListsIn(frameAnalysis:MovieClipFrameAnalysis, checkIfTaken:Boolean):void{
			if(checkIfTaken){
				// we check the movieclip to see if something has taken it as an asset after we stored it.
				var asset:IMovieClip = _nativeFactory.getExisting(frameAnalysis.movieClip);
				if(asset){
					if(!_toRemove)_toRemove = [];
					_toRemove.push(frameAnalysis.movieClip);
					return;
				}
			}
			for each(var stateList:Array in _stateLists){
				for each(var state:IStateDef in stateList){
					if(state.selection!=-1){
						var stateName:String = state.options[state.selection];
						if(stateName){ //  some dynamic assets use null states to allow default styles
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
}