package org.farmcode.actLibrary.display.transition
{
	import org.farmcode.display.assets.utils.snapshot;
	
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.display.DisplayPhases;
	import org.farmcode.actLibrary.display.transition.actTypes.IAdvancedTransitionAct;
	import org.farmcode.actLibrary.display.transition.actTypes.ITransitionAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.utils.isDescendant;
	import org.farmcode.display.transition.TransitionExecution;
	import org.farmcode.display.transition.TransitionManager;
	
	public class TransitionActor extends UniversalActorHelper
	{
		public function get defaultTransitions():Array{
			return _defaultTransitions;
		}
		public function set defaultTransitions(value:Array):void{
			_defaultTransitions = value;
		}
		public function get defaultEasing():Function{
			return _defaultEasing;
		}
		public function set defaultEasing(value:Function):void{
			_defaultEasing = value;
		}
		
		private var _defaultEasing:Function;
		private var _defaultTransitions:Array;
		private var _snapshots:Dictionary = new Dictionary();
		
		public function TransitionActor(defaultTransitions:Array=null, defaultEasing:Function=null){
			this.defaultTransitions = defaultTransitions;
			this.defaultEasing = defaultEasing;
			
			metadataTarget = this;
		}
		
		public var beforeTransitionBeforePhases:Array = [DisplayPhases.DISPLAY_CHANGED];
		[ActRule(ActClassRule,beforePhases="{beforeTransitionBeforePhases}")]
		public function beforeTransition(cause:ITransitionAct):void{
			if(cause.doTransition){
				var adv:IAdvancedTransitionAct = (cause as IAdvancedTransitionAct);
				var startDisplay:IDisplayAsset = (adv && adv.startDisplay?adv.startDisplay:(asset as IContainerAsset));
				var endDisplay:IDisplayAsset = (adv && adv.endDisplay?adv.endDisplay:startDisplay);
				var hiddenDisplay:IDisplayAsset;
				if(startDisplay && !alreadyTransitioning(startDisplay)){
					var castStart:IContainerAsset = (startDisplay as IContainerAsset);
					if(castStart && isDescendant(castStart,endDisplay)){
						endDisplay = startDisplay;
					}else{
						var castEnd:IContainerAsset = (endDisplay as IContainerAsset);
						if(castEnd && isDescendant(castEnd,startDisplay)){
							startDisplay = endDisplay;
						}
					}
					if(startDisplay==endDisplay){
						var depth:Number = 0;
						var parent: IContainerAsset = null;
						var wasVisible:Boolean = startDisplay.visible && startDisplay.stage;
						if (startDisplay == startDisplay.root){
							parent = startDisplay as IContainerAsset;
							depth = parent.numChildren - 1;
						}else{
							parent = startDisplay.parent;
							if(parent){
								depth = parent.getAssetIndex(startDisplay);
								startDisplay.visible = false;
							}
						}
						if(parent){
							if(wasVisible){
								startDisplay = snapshot(startDisplay,parent);
							}else{
								startDisplay = startDisplay.createAsset(IDisplayAsset);
							}
							parent.addAssetAt(startDisplay,depth+1);
						}else if(!wasVisible){
							startDisplay = startDisplay.createAsset(IDisplayAsset);
						}
						hiddenDisplay = endDisplay;
					}
					_snapshots[cause] = new TransBundle(startDisplay, hiddenDisplay, endDisplay);
				}
			}
		}
		protected function alreadyTransitioning(startDisplay:IDisplayAsset):Boolean{
			for each(var transBundle:TransBundle in _snapshots){
				if(transBundle.hiddenDisplay==startDisplay)return true;
			}
			return false;
		}
		
		
		public var transitionPhases:Array = [TransitionPhases.TRANSITION];
		public var transitionAfterPhases:Array = [DisplayPhases.DISPLAY_CHANGED];
		[ActRule(ActClassRule,afterPhases="{transitionAfterPhases}")]
		[ActReaction(phases="{transitionPhases}")]
		public function transition(execution:UniversalActExecution, cause:ITransitionAct):void{
			var bundle:TransBundle = _snapshots[cause];
			if(bundle){
				delete _snapshots[cause];
				if(cause.doTransition){
					var adv:IAdvancedTransitionAct = (cause as IAdvancedTransitionAct);
					bundle.execution = execution;
					var easing:Function = (adv && adv.easing!=null?adv.easing:_defaultEasing);
					var transitions:Array = (adv && adv.transitions?adv.transitions:_defaultTransitions);
					if(transitions && transitions.length){
						var isVisible:Boolean = bundle.endDisplay.visible && bundle.endDisplay.stage;
						if(!isVisible && bundle.endDisplay==bundle.hiddenDisplay){
							bundle.hiddenDisplay = null;
							bundle.endDisplay = bundle.addedDisplay = bundle.startDisplay.createAsset(IDisplayAsset);
							bundle.startDisplay.parent.addAsset(bundle.endDisplay);
						}
						var trans:TransitionExecution = TransitionManager.execute(bundle.startDisplay,bundle.endDisplay,transitions,easing);
						trans.transitionEnd.addHandler(bundle.onFinish);
						return;
					}
				}
				var snapshot:Bitmap = bundle.startDisplay as Bitmap;
				if(snapshot)snapshot.bitmapData.dispose();
				bundle.hiddenDisplay.visible = true;
				bundle.startDisplay.parent.removeAsset(bundle.startDisplay);
			}
		}
	}
}
import flash.display.Bitmap;

import org.farmcode.acting.universal.UniversalActExecution;
import org.farmcode.display.assets.IDisplayAsset;
import org.farmcode.display.transition.TransitionExecution;
	
class TransBundle{
	public var startDisplay:IDisplayAsset;
	public var endDisplay:IDisplayAsset;
	public var hiddenDisplay:IDisplayAsset;
	public var addedDisplay:IDisplayAsset;
	public var execution:UniversalActExecution;
	
	public function TransBundle(startDisplay:IDisplayAsset, hiddenDisplay:IDisplayAsset, endDisplay:IDisplayAsset){
		this.startDisplay = startDisplay;
		this.endDisplay = endDisplay;
		this.hiddenDisplay = hiddenDisplay;
	}
	public function onFinish(from:TransitionExecution):void{
		from.transitionEnd.removeHandler(onFinish);
		var snapshot:Bitmap = startDisplay as Bitmap;
		if(snapshot)snapshot.bitmapData.dispose();
		if(addedDisplay){
			addedDisplay.parent.removeAsset(addedDisplay);
		}
		execution.continueExecution();
	}
}