package org.farmcode.actLibrary.data.actions
{
	import com.asual.swfaddress.SWFAddressUtilities;
	
	import flash.display.DisplayObject;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.external.siteStream.actTypes.ILookupObjectPathAct;
	import org.farmcode.actLibrary.external.swfAddress.SWFAddressPhases;
	import org.farmcode.actLibrary.external.swfAddress.actTypes.ISetSWFAddressAct;
	import org.farmcode.actLibrary.external.swfAddress.acts.GetSWFAddressAct;
	import org.farmcode.actLibrary.external.swfAddress.acts.SetSWFAddressAct;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.rules.ActInstanceRule;
	import org.farmcode.data.actions.AbstractLink;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	
	public class InternalLink extends AbstractLink implements IBooleanConsumer, IBooleanProvider
	{
		public function get swfAddress():String{
			return _triggerAct.swfAddress;
		}
		public function set swfAddress(value:String):void{
			var strict:String;
			if(value){
				strict = SWFAddressUtilities.strictCheck(value,true,true);
			}
			if(_triggerAct.swfAddress != strict){
				_triggerAct.swfAddress = strict;
				checkSelected();
			}
		}
		
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
			}
		}
		
		public function get selectedForSubpages():Boolean{
			return _selectedForSubpages;
		}
		public function set selectedForSubpages(value:Boolean):void{
			if(_selectedForSubpages!=value){
				_selectedForSubpages = value;
				checkSelected();
			}
		}
		public function get scopeDisplay():DisplayObject{
			return _uniActorHelper.scopeDisplay;
		}
		public function set scopeDisplay(value:DisplayObject):void{
			_uniActorHelper.scopeDisplay = value;
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			if(!_booleanValueChanged)_booleanValueChanged = new Act();
			return _booleanValueChanged;
		}
		protected var _booleanValueChanged:Act;
		
		private var _selectedForSubpages:Boolean = true;
		private var _booleanValue:Boolean;
		private var _swfAddress:String;
		private var _currentSwfAddress:String;
		private var _triggerAct:SetSWFAddressAct = new SetSWFAddressAct();
		private var _getSwfAdvice:GetSWFAddressAct = new GetSWFAddressAct();
		private var _uniActorHelper:UniversalActorHelper = new UniversalActorHelper();
		
		public function InternalLink(){
			super();
			
			_uniActorHelper.addedChanged.addHandler(onAddedChanged);
			
			_uniActorHelper.addChild(_triggerAct);
			_uniActorHelper.addChild(_getSwfAdvice);
			
			var methodReaction:MethodReaction = new MethodReaction(onRetrieved,false);
			methodReaction.addUniversalRule(new ActInstanceRule(_getSwfAdvice,null,[SWFAddressPhases.GET_SWF_ADDRESS]));
			_uniActorHelper.addChild(methodReaction);
			
			_uniActorHelper.metadataTarget = this;
		}
		protected function onAddedChanged(from:UniversalActorHelper):void{
			if(_uniActorHelper.added){
				_getSwfAdvice.perform();
			}
		}
		override protected function getAct():IAct{
			return _triggerAct;
		}
		public function onRetrieved(getSwfAdvice:GetSWFAddressAct):void{
			_currentSwfAddress = SWFAddressUtilities.strictCheck(getSwfAdvice.swfAddress,true,true);
			checkSelected();
		}
		public var setAddressAfterPhases:Array = [SWFAddressPhases.SET_SWF_ADDRESS];
		[ActRule(ActClassRule,afterPhases="{setAddressAfterPhases}")]
		public function onSetSWFAddress(cause:ISetSWFAddressAct):void{
			_currentSwfAddress = SWFAddressUtilities.strictCheck(cause.swfAddress,true,true);
			checkSelected();
		}
		protected function checkSelected():void{
			var swfAddress:String = this.swfAddress;
			if(_selectedForSubpages && swfAddress && _currentSwfAddress){
				booleanValue = (_currentSwfAddress.indexOf(swfAddress)==0);
			}else{
				booleanValue = (_currentSwfAddress==swfAddress);
			}
		}
	}
}