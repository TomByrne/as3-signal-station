package org.farmcode.sodalityPlatformEngine.performance
{
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityPlatformEngine.core.advice.ApplicationResizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.advice.RequestApplicationSizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationInitAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationResizeAdvice;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 * This advisor limits the size of the application based on the framerate
	 */
	public class PerformanceSizeAdvisor extends DynamicAdvisor{
		
		public function get lowPerformanceSize():Point{
			return _lowPerformanceSize;
		}
		public function set lowPerformanceSize(value:Point):void{
			//if(!_lowPerformanceSize || !_lowPerformanceSize.equals(value)){
				_lowPerformanceSize = value;
			//}
		}
		public function get lowPerformanceFrames():Number{
			return _lowPerformanceFrames;
		}
		public function set lowPerformanceFrames(value:Number):void{
			//if(_lowPerformanceFrames!=value){
				_lowPerformanceFrames = value;
			//}
		}
		public function get timeFrame():Number{
			return _timeFrame;
		}
		public function set timeFrame(value:Number):void{
			if(_timeFrame!=value){
				_timeFrame = value;
				_lastTimeFrame = getTimer();
				_framesTimeFrame = 0;
			}
		}
		
		private var _lowPerformanceSize:Point = new Point();
		private var _lowPerformanceFrames:Number = 0;
		private var _lastBounds:Rectangle;
		private var _lastStage:Stage;
		private var _fps:Number;
		private var _lastTimeFrame:Number = 0;
		private var _timeFrame:Number = 1000;
		private var _framesTimeFrame:Number = 0;
		
		public function PerformanceSizeAdvisor(){
			super();
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdded);
		}
		private function onAdded(e:AdvisorEvent):void{
			if(_lastStage){
				_lastStage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			_lastStage = advisorDisplay.stage;
			_lastStage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			getSize();
		}
		
		protected function getSize():void{
			var getAppSize:RequestApplicationSizeAdvice = new RequestApplicationSizeAdvice();
			getAppSize.addEventListener(AdviceEvent.COMPLETE, onSizeRetrieved);
			dispatchEvent(getAppSize);
		}
		public function onSizeRetrieved(e:AdviceEvent):void{
			var getAppSize:RequestApplicationSizeAdvice = (e.target as RequestApplicationSizeAdvice);
			_lastBounds = getAppSize.appBounds;
		}
		[Trigger(triggerTiming="before")]
		public function onAppResize(cause: IApplicationResizeAdvice):void{
			if(cause.advisor!=this){
				_lastBounds = cause.appBounds;
				getBounds(cause);
			}
		}
		private function validateSize():void{
			var bounds:Rectangle = getBounds();
			if(bounds)dispatchEvent(new ApplicationResizeAdvice(bounds));
		}
		private function getBounds(cause:IApplicationResizeAdvice=null):Rectangle{
			if(_lastBounds && _lastStage){
				var bounds:Rectangle = _lastBounds.clone();
				var dif:Number;
				var fract:Number = Math.min(Math.max((_fps-_lowPerformanceFrames)/(_lastStage.frameRate-_lowPerformanceFrames),0),1);
				if(fract<1){
					if(_lowPerformanceSize.x<bounds.width){
						dif = (bounds.width-_lowPerformanceSize.x)*(1-fract);
						bounds.x += dif/2;
						bounds.width -= dif;
					}
					if(_lowPerformanceSize.y<bounds.height){
						dif = (bounds.height-_lowPerformanceSize.y)*(1-fract);
						bounds.y += dif/2;
						bounds.height -= dif;
					}
					if(cause)cause.appBounds = bounds;
				}
				return bounds;
			}
			return null;
		}
		private function onEnterFrame( event: Event ): void{
			var time:Number = getTimer();
			if(time > _lastTimeFrame+_timeFrame ){
				_lastTimeFrame = time;
				var fpsWas:Number = _fps;
				_fps = _framesTimeFrame/(_timeFrame/1000);
				if(_fps!=fpsWas){
					validateSize();
				}
				_framesTimeFrame = 0;
			}else{
				++_framesTimeFrame;
			}
		}
	}
}