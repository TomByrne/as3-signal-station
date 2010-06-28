package org.farmcode.actLibrary.external.swfAddress
{
	import com.asual.swfaddress.*;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.external.swfAddress.actTypes.*;
	import org.farmcode.actLibrary.external.swfAddress.acts.*;
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.universal.UniversalActExecution;
	
	
	use namespace ActingNamspace;
	
	public class SWFAddressActor extends UniversalActorHelper
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
		protected var pendingExecutions:Dictionary = new Dictionary();
		
		private var _setSWFAddressAct:SetSWFAddressAct = new SetSWFAddressAct();
		
		public function SWFAddressActor(){
			super();
			SWFAddress.addEventListener(SWFAddressEvent.INIT,onSWFAddressInit);
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE,onSWFAddressChange);
			addChild(_setSWFAddressAct);
			
			metadataTarget = this;
		}
		protected function onSWFAddressInit(event:SWFAddressEvent):void{
			_pageTitle = SWFAddress.getTitle();
		}
		protected function onSWFAddressChange(e:SWFAddressEvent):void{
			var oldValue:String = _swfAddress;
			_swfAddress = e.value;
			
			var execution:UniversalActExecution = pendingExecutions[_swfAddress];
			if(execution){
				delete pendingExecutions[_swfAddress];
				execution.continueExecution();
			}else if(_swfAddress!=oldValue){
				_setSWFAddressAct.swfAddress = _swfAddress;
				_setSWFAddressAct.perform();
			}
		}
		
		public var getSWFAddressPhases:Array = [SWFAddressPhases.GET_SWF_ADDRESS];
		public var getSWFAddressBeforePhases:Array = [SWFAddressPhases.SET_SWF_ADDRESS];
		[ActRule(ActClassRule,beforePhases="{getSWFAddressBeforePhases}")]
		[ActReaction(phases="{getSWFAddressPhases}")]
		public function getSWFAddress(cause:IGetSWFAddressAct):void{
			if(!(cause is ISetSWFAddressAct) && cause!=_setSWFAddressAct){
				fillGetSWFAddress(cause);
			}
		}
		
		public var setSWFAddressPhases:Array = [SWFAddressPhases.SET_SWF_ADDRESS];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{setSWFAddressPhases}")]
		public function setSWFAddress(execution:UniversalActExecution, cause:ISetSWFAddressAct):void{
			var cast:IGetSWFAddressAct = (cause as IGetSWFAddressAct);
			if(cause!=_setSWFAddressAct){
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
						pendingExecutions[newValue] = execution;
						SWFAddress.setValue(newValue);
						return;
					}
				}
			}
			if(cast)fillGetSWFAddress(cast);
			execution.continueExecution();
		}
		public function fillGetSWFAddress(act:IGetSWFAddressAct):void{
			if(_strictRootPathAlias && (_swfAddress=="" || _swfAddress=="/")){
				act.swfAddress = _strictRootPathAlias;
			}else{
				act.swfAddress = _swfAddress;
			}
		}
		
	}
}