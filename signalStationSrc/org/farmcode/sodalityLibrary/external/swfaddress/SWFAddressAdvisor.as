package org.farmcode.sodalityLibrary.external.swfaddress
{
	import com.asual.swfaddress.*;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.external.swfaddress.advice.SetPageTitleAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.advice.SetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.IGetPageTitleAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.IGetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.ISetPageTitleAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.ISetSWFAddressAdvice;
	
	
	public class SWFAddressAdvisor extends DynamicAdvisor
	{
		
		public function get rootPathAlias():String{
			return _rootPathAlias;
		}
		public function set rootPathAlias(value:String):void{
			if(_rootPathAlias!=value){
				var curr:String;
				if(_strictRootPathAlias){
					curr = SWFAddress.getValue();
					if(curr==_strictRootPathAlias){
						SWFAddress.setValue(_strictRootPathAlias);
					}
				}
				_rootPathAlias = value;
				if(SWFAddress.getStrict()){
					_strictRootPathAlias = SWFAddressUtilities.strictCheck(value,true,true);
				}else{
					_strictRootPathAlias = value;
				}
				curr = SWFAddress.getValue();
				if(curr==_strictRootPathAlias){
					SWFAddress.setValue("");
				}
			}
		}
		
		private var _rootPathAlias:String;
		private var _strictRootPathAlias:String;
		protected var _swfAddress:String;
		protected var _pageTitle:String;
		protected var pendingAdvice:Dictionary = new Dictionary();
		
		public function SWFAddressAdvisor(){
			super();
			SWFAddress.addEventListener(SWFAddressEvent.INIT,onSWFAddressInit);
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE,onSWFAddressChange);
		}
		protected function onSWFAddressInit(event:SWFAddressEvent):void{
			_pageTitle = SWFAddress.getTitle();
		}
		protected function onSWFAddressChange(e:SWFAddressEvent):void{
			var oldValue:String = _swfAddress;
			_swfAddress = e.value;
			
			var advice:Advice = pendingAdvice[_swfAddress];
			if(advice){
				delete pendingAdvice[_swfAddress];
				advice.adviceContinue();
			}else if(_swfAddress!=oldValue){
				dispatchEvent(new SetSWFAddressAdvice(_swfAddress));
				dispatchEvent(new SetPageTitleAdvice(_pageTitle));
			}
		}
		
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function afterSetPageTitle(cause:ISetPageTitleAdvice):void{
			if(cause.advisor!=this){
				var newTitle:String = cause.pageTitle?cause.pageTitle:"";
				if(newTitle!=_pageTitle){
					_pageTitle = newTitle;
					SWFAddress.setTitle(_pageTitle);
				}
			}
			var cast:IGetPageTitleAdvice = (cause as IGetPageTitleAdvice);
			if(cast)cast.pageTitle = _pageTitle;
		}
		[Trigger(triggerTiming="before")]
		public function beforeGetPageTitle(cause:IGetPageTitleAdvice):void{
			if(!(cause is ISetPageTitleAdvice)){
				cause.pageTitle = _pageTitle;
			}
		}
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function afterSetSWFAddress(cause:ISetSWFAddressAdvice, advice:AsyncMethodAdvice, timing:String):void{
			var cast:IGetSWFAddressAdvice = (cause as IGetSWFAddressAdvice);
			if(cause.advisor!=this){
				var notSet:Boolean = (!_swfAddress || _swfAddress=="" || _swfAddress=="/");
				if(notSet || !cause.onlyIfNotSet){
					var newValue:String = cause.swfAddress;
					newValue = SWFAddressUtilities.strictCheck(newValue?newValue:"", true, true);
					if(_strictRootPathAlias && newValue==_strictRootPathAlias){
						newValue = "/";
					}
					// For some reason, SWFAddress always returning a strict path
					if(newValue!=_swfAddress){
						_swfAddress = newValue;
						if(cast){
							fillGetSWFAddress(cast);
						}
						pendingAdvice[newValue] = advice;
						SWFAddress.setValue(newValue);
						return;
					}
				}
			}
			if(cast)fillGetSWFAddress(cast);
			advice.adviceContinue();
		}
		[Trigger(triggerTiming="before")]
		public function beforeGetSWFAddress(cause:IGetSWFAddressAdvice):void{
			if(!(cause is ISetSWFAddressAdvice) && cause.advisor!=this){
				fillGetSWFAddress(cause);
			}
		}
		public function fillGetSWFAddress(advice:IGetSWFAddressAdvice):void{
			if(_strictRootPathAlias && (_swfAddress=="" || _swfAddress=="/")){
				advice.swfAddress = _strictRootPathAlias;
			}else{
				advice.swfAddress = _swfAddress;
			}
		}
		
	}
}