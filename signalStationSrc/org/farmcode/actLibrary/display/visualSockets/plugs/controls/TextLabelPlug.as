package org.farmcode.actLibrary.display.visualSockets.plugs.controls
{
	import org.farmcode.actLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.display.behaviour.controls.TextLabel;
	
	public class TextLabelPlug extends AbstractPlugDisplayProxy
	{
		private var textLabel:TextLabel;
		
		public function TextLabelPlug(){
			textLabel = new TextLabel();
			super(textLabel);
		}
		override protected function commitData(execution:UniversalActExecution=null):void{
			textLabel.data = getDataProvider();
		}
		override protected function uncommitData(execution:UniversalActExecution=null):void{
			textLabel.data = null;
		}
	}
}