package org.farmcode.sodalityLibrary.display.visualSockets.mappers
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.farmcode.sodalityLibrary.external.siteStream.advice.ResolvePathsAdvice;
	
	public class SiteStreamPlugMapper extends DynamicAdvisor implements IPlugMapper
	{
		public var forceRefresh:Boolean = false;
		
		private var _pendingAdvice:Dictionary = new Dictionary();
		private var _pendingResults:Dictionary = new Dictionary();
		private var _currentDisplay:IPlugDisplay;
		private var _factoryClassMapping:Dictionary = new Dictionary();
		
		public function SiteStreamPlugMapper(forceRefresh:Boolean=false,  ... klassFactoryMapping){
			this.forceRefresh = forceRefresh;
			for(var i:int=0; i<klassFactoryMapping.length; i+=2){
				var _klass:Class = klassFactoryMapping[i];
				var _factory:IInstanceFactory = klassFactoryMapping[i+1];
				if(_klass && _factory)setFactoryClassMapping(_klass, _factory);
			}
		}
		override public function set addedToPresident(value:Boolean) : void{
			if(super.addedToPresident != value){
				super.addedToPresident = value;
				if(value){
					for(var i:* in _pendingAdvice){
						dispatchEvent(i as Event);
					}
					_pendingAdvice = new Dictionary();
				}
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
			_currentDisplay = currentDisplay;
			if(dataProvider is String){
				var path:String = dataProvider as String;
				if(looksLikePath(path)){
					var result:DisplayCreationResult = new DisplayCreationResult();
					result.complete = false;
					
					var resolvePathsAdvice:ResolvePathsAdvice = new ResolvePathsAdvice([path]);
					_pendingResults[resolvePathsAdvice] = result;
					resolvePathsAdvice.addEventListener(AdviceEvent.COMPLETE, onSiteStreamComplete);
					
					if(this.addedToPresident){
						dispatchEvent(resolvePathsAdvice);
					}else{
						_pendingAdvice[resolvePathsAdvice] = true;
					}
					
					return result;
				}
			}
			return null;
		}
		protected function onSiteStreamComplete(e:AdviceEvent):void{
			var resolvePathsAdvice:ResolvePathsAdvice = (e.target as ResolvePathsAdvice);
			var result:DisplayCreationResult;
			
			for(var i:* in _pendingResults){
				if(Cloner.areClones(resolvePathsAdvice,i)){
					result = _pendingResults[i];
					break;
				}
			}
			
			var resolved:* = resolvePathsAdvice.resolvedObjects[resolvePathsAdvice.resolvePaths[0]];
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
					if (this.forceRefresh || !(displayFactory.matchesType(_currentDisplay))){
						result.result = displayFactory.createInstance();
					}else{
						result.result = _currentDisplay;
					}
				}
			}else{
				trace("WARNING: SiteStreamPlugMapper.onSiteStreamComplete - data was not found for path "+resolvePathsAdvice.resolvePaths[0]);
			}
			result.data = resolved;
			result.complete = true;
			result.dispatchEvent(new Event(Event.COMPLETE));
			
			delete _pendingResults[resolvePathsAdvice];
		}
		protected function looksLikePath(path:String):Boolean{
			return (path.match(/[ .,?!]/)==null);
		}
	}
}