package org.farmcode.sodalityLibrary.core
{
	import au.com.thefarmdigital.debug.toolbar.SimpleDebugToolbar;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	
	import org.farmcode.core.Application;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodality.threading.PresidentThread;
	import org.farmcode.sodalityLibrary.debug.ExecutionChecker;
	import org.farmcode.sodalityLibrary.errors.ErrorAdvisor;
	import org.farmcode.sodalityLibrary.external.siteStream.SiteStreamAdvisor;
	import org.farmcode.sodalityLibrary.external.siteStream.advice.ResolvePathsAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.SWFAddressAdvisor;
	import org.farmcode.sodalityLibrary.utils.config.ConfigAdvisor;
	import org.farmcode.sodalityLibrary.utils.config.advice.SetPropertyConfigParamAdvice;
	import org.farmcode.threading.AbstractThread;
	
	
	/**
	 * ConfiguredApplication adds the functionality to load a configuration file
	 * via SiteStream using Sodality.
	 */
	/*[SWF(width=1000, height=750, frameRate=30, backgroundColor="#ffffff")]
	[Frame(factoryClass="org.farmcode.display.progress.SimpleSWFPreloaderFrame")] */ // this must be on subclass
	public class ConfiguredApplication extends Application implements INonVisualAdvisor, IEventDispatcher
	{
		protected static const CONFIG_URL_PARAM:String = "configURL";
		
		override public function set container(value:DisplayObjectContainer) : void{
			if(super.container && !_lastStage){
				super.container.removeEventListener(Event.ADDED_TO_STAGE, onContainerAdded);
			}
			super.container = value;
			if(super.container && !_lastStage){
				if(super.container.stage){
					_lastStage = container.stage;
					init();
				}else{
					super.container.addEventListener(Event.ADDED_TO_STAGE, onContainerAdded);
				}
				
				/*Config::DEBUG
				{
					_lastStage.setChildIndex(_debugArea,_lastStage.numChildren-1);
				}*/
			}
		}
		public function get configURL():String{
			return _siteStreamAdvisor.rootUrl;
		}
		public function set configURL(value:String):void{
			if(_siteStreamAdvisor.rootUrl != value){
				_siteStreamAdvisor.rootUrl = value;
				if(_dynamicAdvisor.addedToPresident){
					loadConfig();
				}
			}
		}
		
		public function get advisorDisplay():DisplayObject{
			return _dynamicAdvisor.advisorDisplay;
		}
		public function set advisorDisplay(value:DisplayObject):void{
			_dynamicAdvisor.advisorDisplay = value;
		}
		public function get addedToPresident():Boolean{
			return _dynamicAdvisor.addedToPresident;
		}
		public function set addedToPresident(value:Boolean):void{
			_dynamicAdvisor.addedToPresident = value;
		}
		
		protected var _eventDispatcher:EventDispatcher = new EventDispatcher();
		protected var _dynamicAdvisor:DynamicAdvisor;
		protected var _siteStreamAdvisor:SiteStreamAdvisor;
		protected var _lastStage:Stage;
		protected var _swfAddressAdvisor:SWFAddressAdvisor;
		protected var _appConfig:IAppConfig;
		protected var _configAdvisor:ConfigAdvisor;
		
		private var _president:President;
		private var _configURL:String;
		
		Config::DEBUG
		{
			protected var _debugArea:Sprite;
		}
		
		public function ConfiguredApplication(asset:IDisplayAsset=null){
			super(asset);
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAddedToPresident);
		}
		public function onContainerAdded(e:Event):void{
			super.container.removeEventListener(Event.ADDED_TO_STAGE, onContainerAdded);
			_lastStage = container.stage;
			init();
		}
		protected function init():void{
			AbstractThread.intendedFPS = _lastStage.frameRate;
			
			_president = new President(container);
			new PresidentThread(null,1,_president);
			
			_siteStreamAdvisor = new SiteStreamAdvisor();
			_siteStreamAdvisor.advisorDisplay = container;
			
			_swfAddressAdvisor = new SWFAddressAdvisor();
			_swfAddressAdvisor.advisorDisplay = container;
			
			_configAdvisor = new ConfigAdvisor();
			_configAdvisor.defaultConfigs["configURL"] = "xml/config.xml";
			_configAdvisor.defaultConfigs["baseDataURL"] = "";
			_configAdvisor.defaultConfigs["baseClassURL"] = "";
			_configAdvisor.advisorDisplay = container;
			
			var errorAdvisor:ErrorAdvisor = new ErrorAdvisor();
			errorAdvisor.advisorDisplay = container;
			
			_dynamicAdvisor = new DynamicAdvisor(null,this);
			_dynamicAdvisor.advisorDisplay = container;
			
			_dynamicAdvisor.dispatchEvent(new SetPropertyConfigParamAdvice(_siteStreamAdvisor,"baseDataURL","baseDataURL"));
			_dynamicAdvisor.dispatchEvent(new SetPropertyConfigParamAdvice(_siteStreamAdvisor,"baseClassURL","baseClassURL"));
			
			Config::DEBUG
			{
				// testing
				var executionChecker:ExecutionChecker = new ExecutionChecker(container);
				//var siteStreamDebugger:SiteStreamDebugger = new SiteStreamDebugger(_siteStreamAdvisor.siteStream);
				
				/*_debugArea = new Sprite();
				_lastStage.addChild(_debugArea);*/
				
				var onKeyDown:Function = function(e:KeyboardEvent):void{
					if(e.ctrlKey && e.altKey){
						if(e.keyCode==69)executionChecker.printExecutingNodes();	// e
						//if(e.keyCode==83)siteStreamDebugger.printUnresolvedNodes();	// s
					}
				}
				_lastStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				
				var toolbar:SimpleDebugToolbar = new SimpleDebugToolbar(_siteStreamAdvisor.siteStream,_president);
				_lastStage.addChild(toolbar);
			}
		}
		public function onAddedToPresident(e:Event) : void{
			if(configURL){
				loadConfig();
			}else{
				_dynamicAdvisor.dispatchEvent(new SetPropertyConfigParamAdvice(this,"configURL",CONFIG_URL_PARAM));
			}
		}
		protected function loadConfig(): void{
			var getConfig:ResolvePathsAdvice = new ResolvePathsAdvice([""]);
			getConfig.addEventListener(AdviceEvent.COMPLETE, onConfigRetrieved);
			_dynamicAdvisor.dispatchEvent(getConfig);
		}
		protected function onConfigRetrieved(e:AdviceEvent): void{
			var getConfig:ResolvePathsAdvice = (e.target as ResolvePathsAdvice);
			setRootObject(getConfig.resolvedObjects[getConfig.resolvePaths[0]]);
		}
		protected function setRootObject(object:Object):IAdvice{
			_appConfig = (object as IAppConfig);
			var nextAdvice:IAdvice;
			var lastAdvice:IAdvice
			if(_appConfig.initAdvice){
				for(var i:int=0; i<_appConfig.initAdvice.length; i++){
					nextAdvice = _appConfig.initAdvice[i];
					nextAdvice.executeAfter = lastAdvice;
					_dynamicAdvisor.dispatchEvent(nextAdvice as Event);
					lastAdvice = nextAdvice;
				}
			}
			return lastAdvice;
		}
		
		
		
		
		// IEventDispatcher
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function dispatchEvent(event:Event):Boolean{
			return _eventDispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean{
			return _eventDispatcher.hasEventListener(type);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean  = false):void{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		public function willTrigger(type:String):Boolean{
			return _eventDispatcher.willTrigger(type);
		}
	}
}