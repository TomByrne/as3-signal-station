package org.farmcode.actLibrary.display.visualSockets.plugs.controls
{
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.farmcode.actLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.behaviour.controls.TextLabelButton;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	
	public class TextLabelButtonPlug extends AbstractPlugDisplayProxy
	{
		private var _advisorData:INonVisualAdvisor;
		private var _actionData:ITriggerableAction;
		private var _textLabelButton:TextLabelButton;
		
		public function TextLabelButtonPlug(){
			_textLabelButton = new TextLabelButton();
			_textLabelButton.clickAct.addHandler(onButtonClick);
			super(_textLabelButton);
		}
		override protected function commitData(cause:IFillSocketAct=null):void{
			_advisorData = (_dataProvider as INonVisualAdvisor);
			if(_advisorData){
				_advisorData.advisorDisplay = _asset;
			}
			_actionData = (_dataProvider as ITriggerableAction);
			_textLabelButton.data = _dataProvider;
		}
		override protected function uncommitData(cause:IFillSocketAct=null):void{
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
				_dynamicAdvisor.advisorDisplay = _asset;
			}
			if(_advisorData){
				_advisorData.advisorDisplay = _asset;
			}
		}
		protected function onButtonClick(from:TextLabelButton):void{
			if(_actionData){
				_actionData.triggerAct(_asset);
			}
		}
	}
}