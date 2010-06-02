package org.farmcode.sodalityLibrary.external.siteStream
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.siteStream.SiteStream;
	import org.farmcode.siteStream.events.SiteStreamErrorEvent;
	import org.farmcode.sodality.advice.*;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.errors.ErrorDetails;
	import org.farmcode.sodalityLibrary.errors.advice.DetailedErrorAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.ILookupObjectPathAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IReleaseObjectAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IReleasePathAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.errors.SiteStreamErrors;
	import org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger;

	[Event(name="classFailure",type="org.farmcode.siteStream.events.SiteStreamErrorEvent")]
	[Event(name="dataFailure",type="org.farmcode.siteStream.events.SiteStreamErrorEvent")]
	public class SiteStreamAdvisor extends DynamicAdvisor
	{
		public function get rootUrl():String{
			return siteStream.rootURL;
		}
		public function set rootUrl(value:String):void{
			if(value!=siteStream.rootURL){
				siteStream.rootURL = value;
			}
		}
		public function get baseUrl():String{
			if(siteStream.baseClassURL==siteStream.baseDataURL){
				return siteStream.baseClassURL;
			}else{
				return null;
			}
		}
		public function set baseUrl(value:String):void{
			siteStream.baseClassURL = value;
			siteStream.baseDataURL = value;
		}
		public function get baseDataURL():String{
			return siteStream.baseDataURL;
		}
		public function set baseDataURL(value:String):void{
			siteStream.baseDataURL = value;
		}
		public function get baseClassURL():String{
			return siteStream.baseClassURL;
		}
		public function set baseClassURL(value:String):void{
			siteStream.baseClassURL = value;
		}
		public function get siteStream():SiteStream{
			return _siteStream;
		}
		
		protected var _baseUrl:String = "";
		protected var _siteStream:SiteStream;
		protected var loadRequests: Dictionary;
		
		public function SiteStreamAdvisor(){
			this.loadRequests = new Dictionary();
			_siteStream = this.createSiteStream();
			_siteStream.addEventListener(SiteStreamErrorEvent.CLASS_FAILURE, onClassFailure);
			_siteStream.addEventListener(SiteStreamErrorEvent.DATA_FAILURE, onDataFailure);
			
			var includeClass:Class = ImmediateAfterTrigger;
		}
		protected function onClassFailure(e:SiteStreamErrorEvent):void{
			dispatchEvent(new DetailedErrorAdvice(SiteStreamErrors.CLASS_ERROR,new ErrorDetails(e.text)));
		}
		protected function onDataFailure(e:SiteStreamErrorEvent):void{
			dispatchEvent(new DetailedErrorAdvice(SiteStreamErrors.DATA_ERROR,new ErrorDetails(e.text)));
		}
		protected function createSiteStream():SiteStream{
			var ret:SiteStream = new SiteStream();
			return ret;
		}
		
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function beforeLookupObject(cause:ILookupObjectPathAdvice):void{
			if(cause.lookupObject)cause.lookupObjectPath = siteStream.getPath(cause.lookupObject);
		}
		[Trigger(triggerTiming="before")]
		public function beforeResolvePaths(cause:IResolvePathsAdvice, advice: AsyncMethodAdvice, timing:String):void{
			var request: LoadRequest = this.loadRequests[cause];
			if (request){
				request.addPendingAdvice(advice);
				return;
			}else{
				var loadBundles:Array = [];
				for each(var path:String in cause.resolvePaths){
					if(path!=null){
						loadBundles.push(new LoadBundle(path));
					}
				}
				if(loadBundles.length){
					request = new LoadRequest(advice, cause, loadBundles, this);
					this.loadRequests[cause] = request;
					request.startLoad();
					return;
				}
			}
			advice.adviceContinue();
		}
		
		
		public function disposeRequest(request: LoadRequest): void
		{
			var cause:IResolvePathsAdvice = request.cause;
			request.dispose();
			delete this.loadRequests[cause];
		}
		[Trigger(triggerTiming="before")]
		public function releaseRequestPath(cause:IReleasePathAdvice):void{
			siteStream.releaseObject(cause.releasePath);
		}
		[Trigger(triggerTiming="before")]
		public function releaseRequestObject(cause:IReleaseObjectAdvice):void{
			cause.addEventListener(AdviceEvent.CONTINUE, this.handleReleaseContinue);
		}
		
		private function handleReleaseContinue(event: AdviceEvent): void
		{
			var cause: IReleaseObjectAdvice = event.target as IReleaseObjectAdvice;
			cause.removeEventListener(AdviceEvent.CONTINUE, this.handleReleaseContinue);
			
			var path:String = siteStream.getPath(cause.releaseObject);
			if(path)siteStream.releaseObject(path);
		}
	}
}

import org.farmcode.sodality.advice.IAdvice;
import org.farmcode.sodality.advice.Advice;
import org.farmcode.sodalityLibrary.external.siteStream.SiteStreamAdvisor;
import org.farmcode.sodality.events.AdviceEvent;
import flash.events.EventDispatcher;
import flash.events.Event;
import org.farmcode.siteStream.SiteStream;
import org.farmcode.siteStream.events.SiteStreamEvent;
import flash.utils.Dictionary;
import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;

class LoadRequest
{
	public var parent:SiteStreamAdvisor;
	public var pendingAdvices: Array;
	public var cause:IResolvePathsAdvice;
	protected var loadBundles: Array;
	protected var currentBundle:LoadBundle;
	protected var currentLoadIndex: uint;
	
	public function LoadRequest(advice: Advice, cause: IResolvePathsAdvice, loadBundles:Array, parent:SiteStreamAdvisor){
		this.pendingAdvices = [advice];
		this.cause = cause;
		this.parent = parent;
		this.loadBundles = loadBundles;
	}
	
	public function startLoad(): void
	{
		currentLoadIndex = 0;
		loadNextBundle();
	}
	private function loadNextBundle(): void
	{
		if(currentLoadIndex<loadBundles.length){
			var bundle: LoadBundle = loadBundles[currentLoadIndex];
			bundle.addEventListener(Event.COMPLETE, this.handleBundleCompleteEvent);
			bundle.load(this.parent.siteStream);
		}else{
			this.complete();
		}
	}
	
	public function addPendingAdvice(advice: Advice): void{
		if (this.pendingAdvices.indexOf(advice) < 0){
			this.pendingAdvices.push(advice);
		}
	}
		
	protected function handleBundleCompleteEvent(event: Event): void{
		currentLoadIndex++;
		var targetBundle: LoadBundle = event.target as LoadBundle;
		targetBundle.removeEventListener(Event.COMPLETE, this.handleBundleCompleteEvent);
		
		if (!targetBundle.success){
			this.cause.aborted = true;
		}
		loadNextBundle();
	}
	
	public function complete(): void{
		// TODO: Dispose self and dispatch event instead
		var result:Dictionary = new Dictionary();
		for each(var bundle: LoadBundle in loadBundles){
			if(bundle.success){
				result[bundle.path] = bundle.result;
			}
		}
		cause.resolvedObjects = result;
		
		// sometimes dispose gets called as a result of continuing advice, so we need a copy of the array
		var pendingAdvices:Array = this.pendingAdvices.slice();
		for (var i: uint = 0; i < pendingAdvices.length; ++i){
			var advice: Advice = pendingAdvices[i];
			advice.adviceContinue();
		}
		this.parent.disposeRequest(this);
	}
	
	public function dispose(): void{
		this.parent = null;
		this.cause = null;
		this.pendingAdvices = null;
		this.loadBundles = null;
	}
}

[Event(type="flash.events.Event", name="complete")]
class LoadBundle extends EventDispatcher
{
	public var path:String;
	public var success: Boolean;
	private var _result:*;
	
	public function LoadBundle(path:String){
		this.path = path;
	}
	
	public function get result():*{
		return _result;
	}
	
	public function load(siteStream: SiteStream): void{
		siteStream.getObject(path, onItemLoad);
	}
		
	protected function onItemLoad(content:Object):void{
		success = true;
		_result = content;
		dispatchCompleteEvent();
	}
	
	protected function dispatchCompleteEvent(): void{
		dispatchEvent(new Event(Event.COMPLETE));
	}
}
