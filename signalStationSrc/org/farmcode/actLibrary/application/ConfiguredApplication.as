package org.farmcode.actLibrary.application
{
	import flash.display.Sprite;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.errors.ErrorActor;
	import org.farmcode.actLibrary.external.config.ConfigActor;
	import org.farmcode.actLibrary.external.config.acts.SetPropertyConfigParamAct;
	import org.farmcode.actLibrary.external.siteStream.SiteStreamActor;
	import org.farmcode.actLibrary.external.siteStream.SiteStreamPhases;
	import org.farmcode.actLibrary.external.siteStream.acts.ResolvePathsAct;
	import org.farmcode.actLibrary.external.swfAddress.SWFAddressActor;
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.UniversalActManager;
	import org.farmcode.core.Application;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.IScopedObject;
	import org.farmcode.threading.AbstractThread;
	
	use namespace ActingNamspace;
	
	
	/**
	 * ConfiguredApplication adds the functionality to load a configuration file
	 * via SiteStream using Sodality.
	 */
	/*[SWF(width=1000, height=750, frameRate=30, backgroundColor="#ffffff")]
	[Frame(factoryClass="org.farmcode.display.progress.SimpleSWFPreloaderFrame")] */ // this must be on subclass
	public class ConfiguredApplication extends Application
	{
		protected static const CONFIG_URL_PARAM:String = "configURL";
		
		public function get configURL():String{
			return _siteStreamActor.rootUrl;
		}
		public function set configURL(value:String):void{
			if(_siteStreamActor.rootUrl != value){
				_siteStreamActor.rootUrl = value;
				if(container){
					configUrlRetrieved();
				}
			}
		}
		
		protected var _siteStreamActor:SiteStreamActor;
		protected var _configActor:ConfigActor;
		protected var _swfAddressActor:SWFAddressActor;
		protected var _appConfig:IAppConfig;
		
		protected var _universalActorHelper:UniversalActorHelper = new UniversalActorHelper();
		
		private var _configURL:String;
		
		private var _actors:Array = [];
		
		Config::DEBUG{
			protected var _debugArea:Sprite;
		}
		
		public function ConfiguredApplication(asset:IDisplayAsset=null){
			super(asset);
			_universalActorHelper.metadataTarget = this;
			_universalActorHelper.addChild(retrieveConfigUrlAct);
			_universalActorHelper.addChild(retrieveConfigAct);
		}
		override protected function init():void{
			super.init();
			AbstractThread.intendedFPS = _lastStage.frameRate;
			
			_siteStreamActor = new SiteStreamActor();
			addActor(_siteStreamActor);
			
			_swfAddressActor = new SWFAddressActor();
			addActor(_swfAddressActor);
			
			_configActor = new ConfigActor();
			_configActor.defaultConfigs["configURL"] = "xml/config.xml";
			_configActor.defaultConfigs["baseDataURL"] = "";
			_configActor.defaultConfigs["baseClassURL"] = "";
			addActor(_configActor);
			
			var errorActor:ErrorActor = new ErrorActor();
			addActor(errorActor);
			
			Config::DEBUG
			{
				// testing
				/*var executionChecker:ExecutionChecker = new ExecutionChecker(container);
				//var siteStreamDebugger:SiteStreamDebugger = new SiteStreamDebugger(_siteStreamAdvisor.siteStream);
				
				_debugArea = new Sprite();
				_lastStage.addChild(_debugArea);
				
				var onKeyDown:Function = function(e:KeyboardEvent):void{
					if(e.ctrlKey && e.altKey){
						if(e.keyCode==69)executionChecker.printExecutingNodes();	// e
						//if(e.keyCode==83)siteStreamDebugger.printUnresolvedNodes();	// s
					}
				}
				_lastStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				
				var toolbar:SimpleDebugToolbar = new SimpleDebugToolbar(_siteStreamActor.siteStream,_president);
				_debugArea.addChild(toolbar);*/
			}
		}
		protected function addActor(actor:IScopedObject) : void{
			_universalActorHelper.addChild(actor);
		}
		override protected function bindToAsset() : void{
			UniversalActManager.addManager(asset);
			
			super.bindToAsset();
			
			_universalActorHelper.asset = asset;
			
			var act:SetPropertyConfigParamAct = new SetPropertyConfigParamAct(_siteStreamActor,"baseDataURL","baseDataURL");
			act.temporaryPerform(asset);
			
			act = new SetPropertyConfigParamAct(_siteStreamActor,"baseClassURL","baseClassURL");
			act.temporaryPerform(asset);
			
			if(configURL){
				configUrlRetrieved();
			}else{
				retrieveConfigUrlAct.perform();
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			
			_universalActorHelper.asset = null;
			
			UniversalActManager.removeManager(asset);
		}
		
		public var retrieveConfigUrlAct:SetPropertyConfigParamAct = new SetPropertyConfigParamAct(this,"configURL",CONFIG_URL_PARAM);
		public function configUrlRetrieved(): void{
			retrieveConfigAct.perform();
		}
		
		public var retrieveConfigAct:ResolvePathsAct = new ResolvePathsAct([""]);
		public var loadConfigAfterPhases:Array = [SiteStreamPhases.RESOLVE_PATHS];
		[ActRule(ActInstanceRule,act="{retrieveConfigAct}",afterPhases="{loadConfigAfterPhases}")]
		public function onConfigRetrieved(execution:UniversalActExecution, cause:ResolvePathsAct): void{
			setRootObject(execution,cause.resolvedObjects[cause.resolvePaths[0]]);
			execution.continueExecution();
		}
		protected function setRootObject(execution:UniversalActExecution, object:Object):void{
			_appConfig = (object as IAppConfig);
			var act:IUniversalAct;
			if(_appConfig.initActs){
				for(var i:int=0; i<_appConfig.initActs.length; i++){
					temporaryPerformAct(_appConfig.initActs[i],execution);
				}
			}
		}
		protected function temporaryPerformAct(act:IUniversalAct, execution:UniversalActExecution):void{
			act.scope = asset;
			act.perform(execution);
			act.scope = null;
		}
	}
}