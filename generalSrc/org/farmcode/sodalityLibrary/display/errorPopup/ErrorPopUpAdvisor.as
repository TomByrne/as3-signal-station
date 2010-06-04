package org.farmcode.sodalityLibrary.display.errorPopup
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.actLibrary.display.popup.acts.AdvancedAddPopupAct;
	import org.farmcode.sodalityLibrary.errors.ErrorDetails;
	import org.farmcode.sodalityLibrary.errors.IErrorDisplay;
	import org.farmcode.sodalityLibrary.errors.adviceTypes.IDetailedErrorAdvice;
	import org.farmcode.sodalityLibrary.errors.adviceTypes.IErrorAdvice;

	public class ErrorPopUpAdvisor extends DynamicAdvisor
	{
		public var errorDetailsMap:Dictionary;
		public var defaultErrorDisplay:IErrorDisplay;
		public var popUpParent:DisplayObjectContainer;
		
		public function ErrorPopUpAdvisor(advisorDisplay: DisplayObject = null): void
		{
			super(advisorDisplay);
			
			this.errorDetailsMap = new Dictionary();
		}
		
		public function addMapping(id: String, details: ErrorDetails): void
		{
			this.errorDetailsMap[id] = details;
		}
		
		[Trigger(triggerTiming="after")]
		public function onError(cause:IErrorAdvice, advice:AsyncMethodAdvice, timing:String):void{
			if (cause.aborted)
			{
				advice.adviceContinue();
			}
			else
			{
				var details:ErrorDetails = errorDetailsMap[cause.errorType];
				if (details == null && cause is IDetailedErrorAdvice)
				{
					details = (cause as IDetailedErrorAdvice).errorDetails;
				}
				if(details){
					var display:IErrorDisplay = details.errorDisplay?details.errorDisplay:defaultErrorDisplay;
					if(display){
						display.errorDetails = details;
						
						var popUpAdvice:AdvancedAddPopupAct = new AdvancedAddPopupAct();
						popUpAdvice.popUpParent = popUpParent;
						popUpAdvice.display = display.display;
						popUpAdvice.modal = true;
						var bundle:AdviceBundle = new AdviceBundle(advice);
						display.addEventListener(Event.CLOSE, bundle.onClose);
						dispatchEvent(popUpAdvice);
					}
				}
			}
		}
	}
}
import flash.events.Event;
import org.farmcode.sodality.advice.IAdvice;
import org.farmcode.sodality.advice.Advice;
	
class AdviceBundle{
	public var advice:Advice;
	public function AdviceBundle(advice:Advice){
		this.advice = advice;
	}
	public function onClose(e:Event):void{
		advice.adviceContinue();
		e.target.removeEventListener(e.type, onClose);
	}
}