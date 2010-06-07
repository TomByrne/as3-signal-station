package org.farmcode.sodalityWebApp.data.navigation
{
	import com.asual.swfaddress.SWFAddressUtilities;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.external.swfaddress.advice.GetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.advice.SetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.ISetSWFAddressAdvice;
	
	public class InternalLink extends DynamicAdvisor implements IBooleanConsumer, IBooleanProvider, IStringProvider, ITriggerableAction
	{
		
		public function get value():*{
			return stringValue;
		}
		public function get stringValue():String{
			return _stringValue;
		}
		public function set stringValue(value:String):void{
			if(_stringValue != value){
				_stringValue = value;
				if(_stringValueChanged)_stringValueChanged.perform(this)
			}
		}
		
		public function get swfAddress():String{
			return _triggerAction.swfAddress;
		}
		public function set swfAddress(value:String):void{
			var strict:String;
			if(value){
				strict = SWFAddressUtilities.strictCheck(value,true,true);
			}
			if(_triggerAction.swfAddress != strict){
				_triggerAction.swfAddress = strict;
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
		override public function set addedToPresident(value:Boolean):void{
			super.addedToPresident = value;
			if(value){
				var getSwfAdvice:GetSWFAddressAdvice = new GetSWFAddressAdvice();
				getSwfAdvice.addEventListener(AdviceEvent.COMPLETE, onRetrieved);
				dispatchEvent(getSwfAdvice);
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
		
		
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			if(!_booleanValueChanged)_booleanValueChanged = new Act();
			return _booleanValueChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return stringValueChanged;
		}
		
		protected var _stringValueChanged:Act;
		protected var _booleanValueChanged:Act;
		
		private var _selectedForSubpages:Boolean = true;
		private var _booleanValue:Boolean;
		private var _swfAddress:String;
		private var _currentSwfAddress:String;
		private var _stringValue:String;
		private var _triggerAction:SetSWFAddressAdvice = new SetSWFAddressAdvice();
		
		public function InternalLink(){
			super();
		}
		
		public function triggerAction(scopeDisplay:DisplayObject):void{
			if(!advisorDisplay){
				advisorDisplay = scopeDisplay;
			}
			dispatchEvent(_triggerAction);
		}
		public function onRetrieved(e:Event):void{
			var getSwfAdvice:GetSWFAddressAdvice = (e.target as GetSWFAddressAdvice);
			_currentSwfAddress = SWFAddressUtilities.strictCheck(getSwfAdvice.swfAddress,true,true);
			checkSelected();
		}
		[Trigger(triggerTiming="after")]
		public function afterSetSWFAddress(cause:ISetSWFAddressAdvice):void{
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