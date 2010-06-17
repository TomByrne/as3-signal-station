package org.farmcode.actLibrary.display.visualSockets.plugs.controls
{
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.farmcode.actLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	import org.farmcode.display.behaviour.controls.TextLabel;
	
	public class TextLabelPlug extends AbstractPlugDisplayProxy
	{
		private var textLabel:TextLabel;
		
		public function TextLabelPlug(){
			textLabel = new TextLabel();
			super(textLabel);
		}
		override protected function commitData(cause:IFillSocketAct=null):void{
			textLabel.data = getDataProvider();
		}
		override protected function uncommitData(cause:IFillSocketAct=null):void{
			textLabel.data = null;
		}
	}
}