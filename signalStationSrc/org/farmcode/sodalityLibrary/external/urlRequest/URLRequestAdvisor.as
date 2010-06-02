package org.farmcode.sodalityLibrary.external.urlRequest
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.external.urlRequest.adviceTypes.IURLRequestAdvice;
	
	public class URLRequestAdvisor extends DynamicAdvisor
	{
		public function URLRequestAdvisor(){
			super();
		}
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function onURLRequest(cause: IURLRequestAdvice, advice: AsyncMethodAdvice,timing: String): void{
			var request:URLRequest = cause.urlRequest;
			if(request){
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, createContinueHandler(cause,advice));
				urlLoader.load(request);
			}else{
				advice.adviceContinue();
			}
		}
		protected function createContinueHandler(cause:IURLRequestAdvice, advice:Advice):Function{
			return function(e:Event):void{
				var urlLoader:URLLoader = (e.target as URLLoader);
				cause.result = urlLoader.data;
				advice.adviceContinue();
			}
		}
	}
}