package org.farmcode.actLibrary.display.visualSockets.plugs.controls
{
	import org.farmcode.actLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.controls.TextLabelButton;
	import org.farmcode.display.core.IScopedObject;
	
	public class TextLabelButtonPlug extends AbstractPlugDisplayProxy
	{
		
		private var _scopeDisplayData:IScopedObject;
		private var _actionData:ITriggerableAction;
		private var _textLabelButton:TextLabelButton;
		
		public function TextLabelButtonPlug(){
			_textLabelButton = new TextLabelButton();
			_textLabelButton.clicked.addHandler(onButtonClick);
			super(_textLabelButton);
		}
		override protected function commitData(execution:UniversalActExecution=null):void{
			_scopeDisplayData = (_dataProvider as IScopedObject);
			if(_scopeDisplayData && !_scopeDisplayData.scope){
				_scopeDisplayData.scope = _asset;
			}
			_actionData = (_dataProvider as ITriggerableAction);
			_textLabelButton.data = _dataProvider;
		}
		override protected function uncommitData(execution:UniversalActExecution=null):void{
			if(_scopeDisplayData && _scopeDisplayData.scope==_asset){
				_scopeDisplayData.scope = null;
				_scopeDisplayData = null;
			}
			_actionData = null;
			_textLabelButton.data = null;
		}
		override protected function commitAsset():void{
			super.commitAsset();
			if(_scopeDisplayData && !_scopeDisplayData.scope){
				_scopeDisplayData.scope = _asset;
			}
		}
		protected function onButtonClick(from:TextLabelButton):void{
			if(_actionData){
				_actionData.triggerAction(_asset);
			}
		}
	}
}