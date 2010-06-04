package org.farmcode.sodalityPlatformEngine.core
{
	import au.com.thefarmdigital.utils.Context;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodalityLibrary.external.siteStream.SiteStreamAdvisor;
	import org.farmcode.sodalityPlatformEngine.core.advice.ApplicationResizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationInitAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IRequestApplicationSizeAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.SceneAdvisor;

	public class PlatformEngineCore extends DynamicAdvisor
	{
		private static const DEFAULT_BASE_URL: String = "";
		private static const DEFAULT_SITE_STREAM_ROOT: String = "xml/config.xml";
		
		protected var _incAdvisors:Array;
		protected var _advisors:Array;
		protected var _scale:Number = 1;
		protected var _bounds:Rectangle;
		
		protected var _appData:IApplicationData;
		
		protected var context:Context;
		
		public function PlatformEngineCore(context:Context=null, advisorDisplay:DisplayObjectContainer=null)
		{
			if(context){
				var sAdvisor: SceneAdvisor = this.createSceneAdvisor();
				
				context.setDefaultValue(PlatformEngineParameters.BASE_URL,DEFAULT_BASE_URL,true);
				context.setDefaultValue(PlatformEngineParameters.SITE_STREAM_ROOT,DEFAULT_SITE_STREAM_ROOT,true);
				this.context = context;
				
				var ssAdvisor: SiteStreamAdvisor = this.createSiteStreamAdvisor();
				ssAdvisor.baseUrl = context.getValue(PlatformEngineParameters.BASE_URL);
				ssAdvisor.rootUrl = context.getValue(PlatformEngineParameters.SITE_STREAM_ROOT);
				
				_incAdvisors = [sAdvisor,
								ssAdvisor];
				
				this.advisorDisplay = advisorDisplay;
			}
		}
		
		protected function createSceneAdvisor(): SceneAdvisor
		{
			return new SceneAdvisor();
		}
		
		protected function createSiteStreamAdvisor(): SiteStreamAdvisor
		{
			return new SiteStreamAdvisor();
		}
		
		override public function set advisorDisplay(value:DisplayObject):void
		{
			super.advisorDisplay = value;
			this.applyAdvisorDisplays(this._incAdvisors);
			this.applyAdvisorDisplays(this._advisors);
		}
		override public function get advisorDisplay():DisplayObject{
			return super.advisorDisplay;
		}
		
		public function setBounds(bounds:Rectangle):void{
			var scale:Number = 1;
			if(_appData && _appData.minAppSize){
				var width:Number;
				var height:Number;
				if(_appData.scaleBelowMin){
					scale = Math.min(1,bounds.width/_appData.minAppSize.x,bounds.height/_appData.minAppSize.y);
					width = bounds.width/scale;
					height = bounds.height/scale;
				}else{
					width = Math.max(_appData.minAppSize.x,bounds.width);
					height = Math.max(_appData.minAppSize.y,bounds.height);
				}
				bounds.width = width;
				bounds.height = height;
			}
			var scaleChange:Boolean = (_scale!=scale);
			if(!_bounds || !_bounds.equals(bounds) || scaleChange){
				_bounds = bounds;
				if(scaleChange){
					_scale = scale;
					if(_appData)
						_appData.rootDisplay.display.scaleX = _appData.rootDisplay.display.scaleY = _scale;
				}
				dispatchEvent(new ApplicationResizeAdvice(bounds, _scale));
			}
		}
		
		[Trigger(triggerTiming="after")]
		public function onAfterApplicationInit(cause:IApplicationInitAdvice, advice:AsyncMethodAdvice, timing:String):void{
			_appData = cause.applicationData;
			setBounds(_bounds.clone());
			if(_appData){
				if(_appData.rootDisplay){
					_appData.rootDisplay.display.scaleX = _appData.rootDisplay.display.scaleY = _scale;
				}
				_advisors = _appData.advisors.slice();
				this.applyAdvisorDisplays(this._advisors);
				for each(var initAdvice:IAdvice in _appData.initialAdvice){
					initAdvice.executeAfter = cause;
					dispatchEvent(initAdvice as Event);
				}
				
				advice.adviceContinue();
			}else{
				throw new Error("PlatformEngineCore.onAfterApplicationInit: No ApplicationData was found.");
			}
		}
		
		[Trigger(triggerTiming="after")]
		public function onSizeRequest( cause:IRequestApplicationSizeAdvice):void{
			cause.appBounds = _bounds;
			cause.appScale = _scale;
		}
		
		private function applyAdvisorDisplays(advisors: Array): void
		{
			for each(var advisor: INonVisualAdvisor in advisors){
				var nonVis: INonVisualAdvisor = (advisor as INonVisualAdvisor);
				if(nonVis){
					nonVis.advisorDisplay = this.advisorDisplay;
				}
			}
		}
	}
}