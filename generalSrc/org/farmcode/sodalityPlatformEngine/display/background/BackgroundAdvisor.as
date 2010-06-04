package org.farmcode.sodalityPlatformEngine.display.background
{
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityPlatformEngine.core.advice.RequestApplicationSizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationResizeAdvice;
	import org.farmcode.sodalityPlatformEngine.display.background.adviceTypes.IChangeBackgroundAdvice;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BackgroundAdvisor extends DynamicAdvisor
	{
		public function get container():DisplayObjectContainer{
			return _container;
		}
		public function set container(value:DisplayObjectContainer):void{
			if(value!=_container){
				if(_container && _background){
					_container.removeChild(_background);
				}
				_container = value;
				if(_container && _background){
					_container.addChild(_background);
					sizeBackground();
				}
			}
		}
		public function get background():DisplayObject{
			return _background;
		}
		public function set background(value:DisplayObject):void{
			if(value!=_background){
				if(_container && _background){
					_container.removeChild(_background);
				}
				_background = value;
				if(_background){
					if(_container){
						_container.addChild(_background);
						sizeBackground();
					}
				}
			}
		}
		
		private var _container:DisplayObjectContainer;
		private var _background:DisplayObject;
		private var _bounds:Rectangle;
		private var _height:Number;
		
		
		public function BackgroundAdvisor(){
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdded);
		}
		[Trigger(triggerTiming="before")]
		public function onBackgroundChange( cause:IChangeBackgroundAdvice):void
		{
			background = cause.background;
		}
		[Trigger(triggerTiming="after")]
		public function onAppResize(cause: IApplicationResizeAdvice):void{
			_bounds = cause.appBounds;
			sizeBackground();
		}
		private function onAdded(e:Event):void{
			var requestSize:RequestApplicationSizeAdvice = new RequestApplicationSizeAdvice();
			requestSize.addEventListener(AdviceEvent.COMPLETE, onSizeRetrieved);
			dispatchEvent(requestSize);
		}
		private function onSizeRetrieved(e:AdviceEvent):void{
			var requestSize:RequestApplicationSizeAdvice = (e.target as RequestApplicationSizeAdvice);
			if(requestSize.appBounds){
				_bounds = requestSize.appBounds;
				sizeBackground();
			}
		}
		
		protected function sizeBackground():void{
			if(background && _container && _bounds){
				var localPos:Point = _container.globalToLocal(new Point(_bounds.x, _bounds.y));
				background.x = localPos.x;
				background.y = localPos.y;
				background.width = _bounds.width;
				background.height = _bounds.height;
			}
		}
	}
}