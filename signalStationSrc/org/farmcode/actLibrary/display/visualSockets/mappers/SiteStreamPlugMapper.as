package org.farmcode.actLibrary.display.visualSockets.mappers
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.farmcode.actLibrary.external.siteStream.SiteStreamPhases;
	import org.farmcode.actLibrary.external.siteStream.acts.ResolvePathsAct;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.rules.ActInstanceRule;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	public class SiteStreamPlugMapper extends UniversalActorHelper implements IPlugMapper
	{
		public var forceRefresh:Boolean = false;
		
		private var _pendingPaths:Array = [];
		private var _isResolving:Boolean;
		private var _factoryClassMapping:Dictionary = new Dictionary();
		private var _resolvePathsAct:ResolvePathsAct = new ResolvePathsAct();
		
		public function SiteStreamPlugMapper(forceRefresh:Boolean=false,  ... klassFactoryMapping){
			this.forceRefresh = forceRefresh;
			for(var i:int=0; i<klassFactoryMapping.length; i+=2){
				var _klass:Class = klassFactoryMapping[i];
				var _factory:IInstanceFactory = klassFactoryMapping[i+1];
				if(_klass && _factory)setFactoryClassMapping(_klass, _factory);
			}
			
			addChild(_resolvePathsAct);
			
			var methodReaction:MethodReaction = new MethodReaction(onSiteStreamComplete,false);
			methodReaction.addUniversalRule(new ActInstanceRule(_resolvePathsAct,null,[SiteStreamPhases.RESOLVE_PATHS]));
			addChild(methodReaction);
		}
		override protected function setAdded(value:Boolean):void{
			super.setAdded(value);
			if(value){
				resolveNextPath();
			}
		}
		protected function setFactoryClassMapping(klass:Class, factory:IInstanceFactory):void{
			if(factory){
				_factoryClassMapping[klass] = factory;
			}else{
				delete _factoryClassMapping[klass];
			}
		}
		protected function getFactoryClassMapping(klass:Class):IInstanceFactory{
			return _factoryClassMapping[klass];
		}
		protected function clearFactoryClassMapping(klass:Class):IInstanceFactory{
			var ret:IInstanceFactory = _factoryClassMapping[klass];
			delete _factoryClassMapping[klass];
			return ret;
		}
		public function createPlug(dataProvider: *, currentDisplay: IPlugDisplay): DisplayCreationResult{
			if(dataProvider is String){
				var path:String = dataProvider as String;
				if(looksLikePath(path)){
					var result:DisplayCreationResult = new DisplayCreationResult();
					result.complete = false;
					
					_pendingPaths.push(new ResolveBundle(path,result,currentDisplay));
					if(_added){
						resolveNextPath();
					}
					
					return result;
				}
			}
			return null;
		}
		protected function resolveNextPath():void{
			if(!_isResolving && _pendingPaths.length){
				_isResolving = true;
				var bundle:ResolveBundle = _pendingPaths[0];
				_resolvePathsAct.resolvePaths = [bundle.path];
				_resolvePathsAct.perform();
			}
		}
		protected function onSiteStreamComplete(cause:ResolvePathsAct):void{
			_isResolving = false;
			var bundle:ResolveBundle = _pendingPaths.pop();
			var result:DisplayCreationResult = bundle.result;
			
			var resolved:* = cause.resolvedObjects[cause.resolvePaths[0]];
			if(resolved){
				var displayFactory:IInstanceFactory = _factoryClassMapping[resolved.constructor];
				if(!displayFactory){
					for(var klass:* in _factoryClassMapping){
						if(resolved is klass){
							displayFactory = _factoryClassMapping[klass];
							break;
						}
					}
				}
				if(displayFactory){
					if (this.forceRefresh || !(displayFactory.matchesType(bundle.display))){
						result.result = displayFactory.createInstance();
					}else{
						result.result = bundle.display;
					}
				}
			}else{
				trace("WARNING: SiteStreamPlugMapper.onSiteStreamComplete - data was not found for path "+cause.resolvePaths[0]);
			}
			result.data = resolved;
			result.complete = true;
			result.dispatchEvent(new Event(Event.COMPLETE));
			
			resolveNextPath();
		}
		protected function looksLikePath(path:String):Boolean{
			return (path.match(/[ .,?!]/)==null);
		}
	}
}
// TODO: pool ResolveBundles
import org.farmcode.actLibrary.display.visualSockets.mappers.DisplayCreationResult;
import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;

class ResolveBundle{
	public var path:String;
	public var result:DisplayCreationResult;
	public var display: IPlugDisplay;
	
	public function ResolveBundle(path:String, result:DisplayCreationResult, display: IPlugDisplay){
		this.path = path;
		this.result = result;
		this.display = display;
	}
	
}