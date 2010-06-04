package org.farmcode.sodalityPlatformEngine.display
{
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityLibrary.display.AdvisorView;
	import org.farmcode.sodalityPlatformEngine.core.advice.RequestApplicationSizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationResizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IRequestApplicationSizeAdvice;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ApplicationSizeView extends AdvisorView
	{
		protected var _bounds:Rectangle;
		
		public function ApplicationSizeView(){
			super(true);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdvisorAdded);
		}
		
		protected function get boundsRetrieved(): Boolean
		{
			return this._bounds != null;
		}
		
		private function onAdded(e:Event):void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			if(_bounds){
				setBounds(_bounds);
			}
		}
		private function onAdvisorAdded(event: AdvisorEvent): void
		{
			if (!this._bounds){
				var requestSize:RequestApplicationSizeAdvice = new RequestApplicationSizeAdvice();
				requestSize.addEventListener(AdviceEvent.COMPLETE, onSizeRetrieved);
				dispatchEvent(requestSize);
			}
		}
		
		private function onRemoved(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			_bounds = null;
		}
		private function onSizeRetrieved(e:AdviceEvent):void{
			var requestSize:IRequestApplicationSizeAdvice = (e.target as IRequestApplicationSizeAdvice);
			requestSize.removeEventListener(e.type, onSizeRetrieved);
			if (this.parent)
			{
				if(requestSize.appBounds)setBounds(requestSize.appBounds);
			}
		}
		
		[Trigger(triggerTiming="after")]
		public function onAppResize( cause: IApplicationResizeAdvice):void{
			setBounds(cause.appBounds);
		}
		protected function setBounds(bounds:Rectangle):void{
			_bounds = bounds;
			if(stage){
				var pos:Point = parent.globalToLocal(new Point(bounds.x,bounds.y));
				this.x = pos.x;
				this.y = pos.y;
				this.width = bounds.width;
				this.height = bounds.height;
				validate();
			}
		}
	}
}