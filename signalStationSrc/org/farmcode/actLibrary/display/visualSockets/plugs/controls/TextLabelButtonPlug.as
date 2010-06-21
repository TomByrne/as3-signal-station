package org.farmcode.actLibrary.display.visualSockets.plugs.controls
{
	import org.farmcode.actLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	import org.farmcode.acting.IScopeDisplayObject;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.behaviour.controls.TextLabelButton;
	
	public class TextLabelButtonPlug extends AbstractPlugDisplayProxy
	{
		
		private var _scopeDisplayData:IScopeDisplayObject;
		private var _actionData:ITriggerableAction;
		private var _textLabelButton:TextLabelButton;
		
		public function TextLabelButtonPlug(){
			_textLabelButton = new TextLabelButton();
			_textLabelButton.clickAct.addHandler(onButtonClick);
			super(_textLabelButton);
		}
		override protected function commitData(execution:UniversalActExecution=null):void{
			_scopeDisplayData = (_dataProvider as IScopeDisplayObject);
			if(_scopeDisplayData && !_scopeDisplayData.scopeDisplay){
				_scopeDisplayData.scopeDisplay = _asset;
			}
			_actionData = (_dataProvider as ITriggerableAction);
			_textLabelButton.data = _dataProvider;
		}
		override protected function uncommitData(execution:UniversalActExecution=null):void{
			if(_scopeDisplayData && _scopeDisplayData.scopeDisplay==_asset){
				_scopeDisplayData.scopeDisplay = null;
				_scopeDisplayData = null;
			}
			_actionData = null;
			_textLabelButton.data = null;
		}
		override protected function commitAsset():void{
			super.commitAsset();
			if(_scopeDisplayData && !_scopeDisplayData.scopeDisplay){
				_scopeDisplayData.scopeDisplay = _asset;
			}
		}
		protected function onButtonClick(from:TextLabelButton):void{
			if(_actionData){
				_actionData.triggerAction(_asset);
			}
		}
	}
}