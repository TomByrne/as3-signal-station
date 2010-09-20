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
	import org.farmcode.core.EnterFrameHook;
	import org.farmcode.debug.DebugManager;
	import org.farmcode.debug.data.core.DebugData;
	import org.farmcode.debug.nodes.DebugDataNode;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
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
		protected static const CONFIG_URL_PARAM:String = "configUrl";
		
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
		override public function set container(value:IContainerAsset):void{
			if(!_scopeDisplay)setScopeDisplay(value);
			super.container = value;
		}
		
		protected var _scopeDisplay:IDisplayAsset;
		protected var _siteStreamActor:SiteStreamActor;
		protected var _configActor:ConfigActor;
		protected var _swfAddressActor:SWFAddressActor;
		protected var _appConfig:IAppConfig;
		
		protected var _universalActorHelper:UniversalActorHelper = new UniversalActorHelper();
		
		private var _configURL:String;
		
		private var _actors:Array = [];
		
		public function ConfiguredApplication(){
			_universalActorHelper.metadataTarget = this;
			_universalActorHelper.addChild(retrieveConfigUrlAct);
			_universalActorHelper.addChild(retrieveConfigAct);
			_universalActorHelper.addedChanged.addTempHandler(onAdded);
			
			_siteStreamActor = new SiteStreamActor();
			addActor(_siteStreamActor);
			
			_swfAddressActor = new SWFAddressActor();
			
			_configActor = new ConfigActor();
			setDefaultConfig(CONFIG_URL_PARAM,"xml/config.xml");
			setDefaultConfig("baseDataURL","");
			setDefaultConfig("baseClassURL","");
			addActor(_configActor);
			
			var errorActor:ErrorActor = new ErrorActor();
			addActor(errorActor);
		}
		protected function onAdded(from:UniversalActorHelper) : void{
			// we delay for a frame to make sure all Universal stuff is ready 
			EnterFrameHook.getAct().addTempHandler(attemptInit);
		}
		override protected function commitStage() : void{
			super.commitStage();
			if(isNaN(AbstractThread.intendedFPS)){
				AbstractThread.intendedFPS = _lastStage.frameRate;
			}
		}
		override protected function init():void{
			addActor(_swfAddressActor);
			super.init();
			
			Config::DEBUG{
				if(!_scopeDisplay || !_universalActorHelper.added){
					throw new Error("Cannot init before the container has been set");
				}
				DebugManager.addDebugNode(new DebugDataNode(_scopedObject,new DebugData(_swfAddressActor.currentPath)));
			}
			
			var act:SetPropertyConfigParamAct = new SetPropertyConfigParamAct(_siteStreamActor,"baseDataURL","baseDataURL");
			act.temporaryPerform(_scopeDisplay);
			
			act = new SetPropertyConfigParamAct(_siteStreamActor,"baseClassURL","baseClassURL");
			act.temporaryPerform(_scopeDisplay);
			
			if(configURL){
				configUrlRetrieved();
			}else{
				retrieveConfigUrlAct.perform();
			}
		}
		protected function setDefaultConfig(name:String, value:String) : void{
			if(_configActor)_configActor.defaultConfigs[name] = value;
			else if(_lastStage){
				if(!_lastStage.loaderInfo.parameters[name])
					_lastStage.loaderInfo.parameters[name] = value;
			}else{
				throw new Error("Can't set default config values yet");
			}
		}
		protected function addActor(actor:IScopedObject) : void{
			_universalActorHelper.addChild(actor);
		}
		override protected function setAsset(value:IDisplayAsset) : void{
			if(_scopeDisplay==_asset)setScopeDisplay(null);
			super.setAsset(value);
			if(value)setScopeDisplay(value);
			else if(!_scopeDisplay)setScopeDisplay(_container);
		}
		protected function setScopeDisplay(value:IDisplayAsset) : void{
			if(_scopeDisplay!=value){
				if(_scopeDisplay){
					UniversalActManager.removeManager(_scopeDisplay);
				}
				_scopeDisplay = value;
				if(value){
					UniversalActManager.addManager(value);
				}
				_universalActorHelper.asset = value;
			}
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
			
			if(!_asset && _castMainView && _appConfig.assetFactory){
				_castMainView.asset = _appConfig.assetFactory.getCoreSkin(getCoreSkinName()) as IDisplayAsset;
			}
			
			var act:IUniversalAct;
			if(_appConfig.initActs){
				for(var i:int=0; i<_appConfig.initActs.length; i++){
					temporaryPerformAct(_appConfig.initActs[i],execution);
				}
			}
			if(!isNaN(_appConfig.applicationScale))applicationScale = _appConfig.applicationScale;
		}
		protected function getCoreSkinName():String{
			throw new Error("getCoreSkinName should be overriden");
		}
		protected function temporaryPerformAct(act:IUniversalAct, execution:UniversalActExecution):void{
			act.scope = _asset;
			act.perform(execution);
			act.scope = null;
		}
	}
}
import org.farmcode.acting.universal.rules.ActClassRule;
import org.farmcode.acting.universal.rules.ActInstanceRule;

class ClassIncluder{
	public function ClassIncluder(){
		var includeClass:Class;
		includeClass = ActClassRule;
		includeClass = ActInstanceRule;
	}
}