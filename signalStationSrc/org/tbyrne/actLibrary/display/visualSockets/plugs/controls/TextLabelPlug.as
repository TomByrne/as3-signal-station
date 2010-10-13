package org.tbyrne.actLibrary.display.visualSockets.plugs.controls
{
	import org.tbyrne.actLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.display.controls.TextLabel;
	
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