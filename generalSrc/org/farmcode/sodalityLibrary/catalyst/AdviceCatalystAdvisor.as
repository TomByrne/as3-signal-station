package org.farmcode.sodalityLibrary.catalyst
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.IDynamicAdvisor;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class AdviceCatalystAdvisor extends DynamicAdvisor
	{
		public function get adviceCatalyst():IAdviceCatalyst{
			return _adviceCatalyst;
		}
		public function set adviceCatalyst(value:IAdviceCatalyst):void{
			if(_adviceCatalyst!=value){
				if(_adviceCatalyst)_adviceCatalyst.removeEventListener(AdviceCatalystEvent.CATALYST_MET, onCatalystMet);
				_adviceCatalyst = value;
				_adviceCatalyst.addEventListener(AdviceCatalystEvent.CATALYST_MET, onCatalystMet);
				if(_adviceCatalyst is INonVisualAdvisor){
					(_adviceCatalyst as INonVisualAdvisor).advisorDisplay = advisorDisplay;
				}
			}
		}
		override public function set advisorDisplay(value:DisplayObject):void{
			if(_adviceCatalyst is INonVisualAdvisor){
				(_adviceCatalyst as INonVisualAdvisor).advisorDisplay = value;
			}
			super.advisorDisplay = advisorDisplay;
		}
		
		public var adviceList:Array;
		private var _adviceCatalyst:IAdviceCatalyst;
		
		public function AdviceCatalystAdvisor(){
			super();
		}
		protected function onCatalystMet(e:Event):void{
			for each(var advice:IAdvice in adviceList){
				dispatchEvent(advice as Event);
			}
		}
	}
}