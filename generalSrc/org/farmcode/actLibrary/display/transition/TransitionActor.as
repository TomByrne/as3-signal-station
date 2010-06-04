package org.farmcode.actLibrary.display.transition
{
	import au.com.thefarmdigital.events.TransitionEvent;
	import au.com.thefarmdigital.utils.DisplayObjectSnapshot;
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.display.DisplayPhases;
	import org.farmcode.actLibrary.display.transition.actTypes.IAdvancedTransitionAct;
	import org.farmcode.actLibrary.display.transition.actTypes.ITransitionAct;
	import org.farmcode.acting.universal.UniversalActExecution;
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
				var startDisplay:DisplayObject = (adv && adv.startDisplay?adv.startDisplay:(scopeDisplay as DisplayObjectContainer));
				var endDisplay:DisplayObject = (adv && adv.endDisplay?adv.endDisplay:startDisplay);
				var hiddenDisplay:DisplayObject;
				if(startDisplay && !alreadyTransitioning(startDisplay)){
					var castStart:DisplayObjectContainer = (startDisplay as DisplayObjectContainer);
					if(castStart && DisplayUtils.isDescendant(castStart,endDisplay)){
						endDisplay = startDisplay;
					}else{
						var castEnd:DisplayObjectContainer = (endDisplay as DisplayObjectContainer);
						if(castEnd && DisplayUtils.isDescendant(castEnd,startDisplay)){
							startDisplay = endDisplay;
						}
					}
					if(startDisplay==endDisplay){
						var depth:Number = 0;
						var parent: DisplayObjectContainer = null;
						var wasVisible:Boolean = startDisplay.visible && startDisplay.stage;
						if (startDisplay == startDisplay.root){
							parent = startDisplay as DisplayObjectContainer;
							depth = parent.numChildren - 1;
						}else{
							parent = startDisplay.parent;
							if(parent){
								depth = parent.getChildIndex(startDisplay);
								startDisplay.visible = false;
							}
						}
						if(parent){
							if(wasVisible){
								startDisplay = DisplayObjectSnapshot.snapshot(startDisplay,parent);
							}else{
								startDisplay = new Sprite();
							}
							parent.addChildAt(startDisplay,depth+1);
						}else if(!wasVisible){
							startDisplay = new Sprite();
						}
						hiddenDisplay = endDisplay;
					}
					_snapshots[cause] = new TransBundle(startDisplay, hiddenDisplay, endDisplay);
				}
			}
		}
		protected function alreadyTransitioning(startDisplay:DisplayObject):Boolean{
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
							bundle.endDisplay = bundle.addedDisplay = new Sprite();
							bundle.startDisplay.parent.addChild(bundle.endDisplay);
						}
						var trans:TransitionExecution = TransitionManager.execute(bundle.startDisplay,bundle.endDisplay,transitions,easing);
						trans.addEventListener(TransitionEvent.TRANSITION_END, bundle.onFinish);					
						return;
					}
				}
				var snapshot:Bitmap = bundle.startDisplay as Bitmap;
				if(snapshot)snapshot.bitmapData.dispose();
				bundle.hiddenDisplay.visible = true;
				bundle.startDisplay.parent.removeChild(bundle.startDisplay);
			}
		}
	}
}
import au.com.thefarmdigital.events.TransitionEvent;

import flash.display.Bitmap;
import flash.display.DisplayObject;

import org.farmcode.acting.universal.UniversalActExecution;
import org.farmcode.sodality.advice.Advice;
	
class TransBundle{
	public var startDisplay:DisplayObject;
	public var endDisplay:DisplayObject;
	public var hiddenDisplay:DisplayObject;
	public var addedDisplay:DisplayObject;
	public var execution:UniversalActExecution;
	
	public function TransBundle(startDisplay:DisplayObject, hiddenDisplay:DisplayObject, endDisplay:DisplayObject){
		this.startDisplay = startDisplay;
		this.endDisplay = endDisplay;
		this.hiddenDisplay = hiddenDisplay;
	}
	public function onFinish(e:TransitionEvent):void{
		var snapshot:Bitmap = startDisplay as Bitmap;
		if(snapshot)snapshot.bitmapData.dispose();
		if(addedDisplay){
			addedDisplay.parent.removeChild(addedDisplay);
		}
		execution.continueExecution();
	}
}