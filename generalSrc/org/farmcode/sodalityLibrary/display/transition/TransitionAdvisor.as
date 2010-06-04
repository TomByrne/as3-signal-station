package org.farmcode.sodalityLibrary.display.transition
{
	import au.com.thefarmdigital.events.TransitionEvent;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.display.transition.adviceTypes.*;
	import au.com.thefarmdigital.transitions.TransitionExecution;
	import au.com.thefarmdigital.transitions.TransitionManager;
	import au.com.thefarmdigital.utils.DisplayObjectSnapshot;
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	public class TransitionAdvisor extends DynamicAdvisor
	{
		public function get defaultTransitions():Array{
			return _defaultTransitions;
		}
		public function set defaultTransitions(value:Array):void{
			//if(value!=_defaultTransitions){
				_defaultTransitions = value;
			//}
		}
		public function get defaultDisplay():DisplayObjectContainer{
			return _defaultDisplay;
		}
		public function set defaultDisplay(value:DisplayObjectContainer):void{
			if(value!=_defaultDisplay){
				_defaultDisplay = value;
			}
		}
		public function get defaultEasing():Function{
			return _defaultEasing;
		}
		public function set defaultEasing(value:Function):void{
			//if(value!=_defaultEasing){
				_defaultEasing = value;
			//}
		}
		
		private var _defaultEasing:Function;
		private var _defaultDisplay:DisplayObjectContainer;
		private var _defaultTransitions:Array;
		private var _snapshots:Dictionary = new Dictionary();
		
		public function TransitionAdvisor(){
		}
		
		[Trigger(triggerTiming="before")]
		public function onTransitionBefore(cause:ITransitionAdvice):void
		{
			if(cause.doTransition)
			{
				var adv:IAdvancedTransitionAdvice = (cause as IAdvancedTransitionAdvice);
				var startDisplay:DisplayObject = (adv && adv.startDisplay?adv.startDisplay:_defaultDisplay);
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
						var wasVisible:Boolean = startDisplay.visible;
						if (startDisplay == startDisplay.root)
						{
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
							startDisplay = wasVisible?DisplayObjectSnapshot.snapshot(startDisplay,parent):new Sprite();
							hiddenDisplay = startDisplay;
							parent.addChildAt(startDisplay,depth+1);
						}
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
		
		
		[Trigger(triggerTiming="after")]
		public function onTransitionAfter(cause:ITransitionAdvice, advice:AsyncMethodAdvice, 
			timing:String):void
		{
			var bundle:TransBundle = _snapshots[cause];
			if(bundle){
				delete _snapshots[cause];
				if(cause.doTransition){
					var adv:IAdvancedTransitionAdvice = (cause as IAdvancedTransitionAdvice);
					bundle.advice = advice;
					var easing:Function = (adv && adv.easing!=null?adv.easing:_defaultEasing);
					var transitions:Array = (adv && adv.transitions?adv.transitions:_defaultTransitions);
					if(transitions && transitions.length){
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
			advice.adviceContinue();
		}
	}
}
import flash.display.DisplayObject;
import org.farmcode.sodality.advice.Advice;
import au.com.thefarmdigital.events.TransitionEvent;
import flash.display.Bitmap;
import flash.system.System;
	
class TransBundle{
	public var startDisplay:DisplayObject;
	public var endDisplay:DisplayObject;
	public var hiddenDisplay:DisplayObject;
	public var advice:Advice;
	
	public function TransBundle(startDisplay:DisplayObject, hiddenDisplay:DisplayObject, endDisplay:DisplayObject){
		this.startDisplay = startDisplay;
		this.endDisplay = endDisplay;
		this.hiddenDisplay = hiddenDisplay;
	}
	public function onFinish(e:TransitionEvent):void{
		var snapshot:Bitmap = startDisplay as Bitmap;
		if(snapshot)snapshot.bitmapData.dispose();
		advice.adviceContinue();
	}
}