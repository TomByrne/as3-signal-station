package org.farmcode.sodalityLibrary.display.visualSockets.plugs.controls
{
	import flash.events.Event;
	
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.controls.TextLabelButton;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	
	public class TextLabelButtonPlug extends AbstractPlugDisplayProxy
	{
		private var _advisorData:INonVisualAdvisor;
		private var _actionData:ITriggerableAction;
		private var _dynamicAdvisor:DynamicAdvisor;
		private var _textLabelButton:TextLabelButton;
		
		public function TextLabelButtonPlug(){
			_textLabelButton = new TextLabelButton();
			_textLabelButton.clickAct.addHandler(onButtonClick);
			super(_textLabelButton);
		}
		override protected function commitData(cause:IAdvice=null):void{
			_advisorData = (_dataProvider as INonVisualAdvisor);
			if(_advisorData){
				_advisorData.advisorDisplay = _asset?_asset.drawDisplay:null;
			}
			_actionData = (_dataProvider as ITriggerableAction);
			_textLabelButton.data = _dataProvider;
		}
		override protected function uncommitData(cause:IAdvice=null):void{
			if(_advisorData){
				_advisorData.advisorDisplay = null;
				_advisorData = null;
			}
			_actionData = null;
			_textLabelButton.data = null;
		}
		override protected function commitAsset():void{
			super.commitAsset();
			if(_dynamicAdvisor){
				_dynamicAdvisor.advisorDisplay = _asset?_asset.drawDisplay:null;
			}
			if(_advisorData){
				_advisorData.advisorDisplay = _asset?_asset.drawDisplay:null;
			}
		}
		// TODO: clean this shit up (triggerAction probably gets called already in Button)
		protected function onButtonClick(from:TextLabelButton):void{
			if(_actionData){
				_actionData.triggerAction(_asset.drawDisplay);
				/*var advice:IAdvice = _actionData.triggerAction(_asset.drawDisplay);
				if(advice){
					if(!_dynamicAdvisor){
						_dynamicAdvisor = new DynamicAdvisor();
					}
					_dynamicAdvisor.advisorDisplay = _asset?_asset.drawDisplay:null;
					_dynamicAdvisor.dispatchEvent(advice as Event);
				}*/
			}
		}
	}
}