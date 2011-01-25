package org.tbyrne.actLibrary.external.swfAddress
{
	import com.asual.swfaddress.*;
	
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.external.swfAddress.actTypes.*;
	import org.tbyrne.actLibrary.external.swfAddress.acts.*;
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	
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
		public function get currentPath():IStringProvider{
			return _currentPath;
		}
		
		private var _rootPathAlias:String;
		private var _strictRootPathAlias:String;
		protected var _swfAddress:String;
		protected var _currentPath:StringData = new StringData();
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
		override protected function setAdded(value:Boolean):void{
			super.setAdded(value);
			if(value)checkAddress();
		}
		protected function onSWFAddressInit(event:SWFAddressEvent):void{
			_pageTitle = SWFAddress.getTitle();
		}
		protected function onSWFAddressChange(e:SWFAddressEvent):void{
			if(added)checkAddress();
		}
		protected function checkAddress():void{
			var oldValue:String = _currentPath.stringValue;
			var newValue:String = SWFAddress.getValue();
			
			var execution:UniversalActExecution = pendingExecutions[newValue];
			if(execution){
				_currentPath.stringValue = newValue;
				delete pendingExecutions[newValue];
				execution.continueExecution();
			}else if(newValue!=oldValue){
				_setSWFAddressAct.swfAddress = newValue;
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
			if(cause!=_setSWFAddressAct){
				var cast:IGetSWFAddressAct = (cause as IGetSWFAddressAct);
				var oldValue:String = _currentPath.stringValue;
				var notSet:Boolean = (!oldValue || oldValue=="" || oldValue=="/");
				if(notSet || !cause.onlyIfNotSet){
					var newValue:String = cause.swfAddress;
					newValue = SWFAddressUtilities.strictCheck(newValue?newValue:"", true, true);
					if(_strictRootPathAlias && newValue==_strictRootPathAlias){
						newValue = "/";
					}
					// For some reason, SWFAddress always returning a strict path
					if(newValue!=oldValue){
						_currentPath.stringValue = newValue;
						if(cast){
							fillGetSWFAddress(cast);
						}
						pendingExecutions[newValue] = execution;
						SWFAddress.setValue(newValue);
						return;
					}
				}
				if(cast)fillGetSWFAddress(cast);
			}
			execution.continueExecution();
		}
		public function fillGetSWFAddress(act:IGetSWFAddressAct):void{
			if(_strictRootPathAlias && (_swfAddress=="" || _swfAddress=="/")){
				act.swfAddress = _strictRootPathAlias;
			}else{
				act.swfAddress = _currentPath.stringValue;
			}
		}
		
	}
}