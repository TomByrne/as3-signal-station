package org.tbyrne.actLibrary.display.transition
{
	import org.tbyrne.display.assets.utils.snapshot;
	
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.display.DisplayPhases;
	import org.tbyrne.actLibrary.display.transition.actTypes.IAdvancedTransitionAct;
	import org.tbyrne.actLibrary.display.transition.actTypes.ITransitionAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.utils.isDescendant;
	import org.tbyrne.display.transition.TransitionExecution;
	import org.tbyrne.display.transition.TransitionManager;
	
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
		[ActRule(ActClassRule,beforePhases="<beforeTransitionBeforePhases>")]
		public function beforeTransition(cause:ITransitionAct):void{
			if(cause.doTransition){
				var adv:IAdvancedTransitionAct = (cause as IAdvancedTransitionAct);
				var startDisplay:IDisplayObject = (adv && adv.startDisplay?adv.startDisplay:(asset as IDisplayObjectContainer));
				var endDisplay:IDisplayObject = (adv && adv.endDisplay?adv.endDisplay:startDisplay);
				var hiddenDisplay:IDisplayObject;
				if(startDisplay && !alreadyTransitioning(startDisplay)){
					var castStart:IDisplayObjectContainer = (startDisplay as IDisplayObjectContainer);
					if(castStart && isDescendant(castStart,endDisplay)){
						endDisplay = startDisplay;
					}else{
						var castEnd:IDisplayObjectContainer = (endDisplay as IDisplayObjectContainer);
						if(castEnd && isDescendant(castEnd,startDisplay)){
							startDisplay = endDisplay;
						}
					}
					if(startDisplay==endDisplay){
						var depth:Number = 0;
						var parent: IDisplayObjectContainer = null;
						var wasVisible:Boolean = startDisplay.visible && startDisplay.stage;
						if (startDisplay == startDisplay.stage){
							parent = startDisplay as IDisplayObjectContainer;
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
								startDisplay = startDisplay.factory.createContainer();
							}
							parent.addAssetAt(startDisplay,depth+1);
						}else if(!wasVisible){
							startDisplay = startDisplay.factory.createContainer();
						}
						hiddenDisplay = endDisplay;
					}
					_snapshots[cause] = new TransBundle(startDisplay, hiddenDisplay, endDisplay);
				}
			}
		}
		protected function alreadyTransitioning(startDisplay:IDisplayObject):Boolean{
			for each(var transBundle:TransBundle in _snapshots){
				if(transBundle.hiddenDisplay==startDisplay)return true;
			}
			return false;
		}
		
		
		public var transitionPhases:Array = [TransitionPhases.TRANSITION];
		public var transitionAfterPhases:Array = [DisplayPhases.DISPLAY_CHANGED];
		[ActRule(ActClassRule,afterPhases="<transitionAfterPhases>")]
		[ActReaction(phases="<transitionPhases>")]
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
							bundle.endDisplay = bundle.addedDisplay = bundle.startDisplay.factory.createContainer();
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

import org.tbyrne.acting.universal.UniversalActExecution;
import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
import org.tbyrne.display.transition.TransitionExecution;
	
class TransBundle{
	public var startDisplay:IDisplayObject;
	public var endDisplay:IDisplayObject;
	public var hiddenDisplay:IDisplayObject;
	public var addedDisplay:IDisplayObject;
	public var execution:UniversalActExecution;
	
	public function TransBundle(startDisplay:IDisplayObject, hiddenDisplay:IDisplayObject, endDisplay:IDisplayObject){
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