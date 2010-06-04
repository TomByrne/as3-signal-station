package org.farmcode.sodalityLibrary.display.visualSockets.plugs.controls
{
	import org.farmcode.display.controls.TextLabel;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	
	public class TextLabelPlug extends AbstractPlugDisplayProxy
	{
		private var textLabel:TextLabel;
		
		public function TextLabelPlug(){
			textLabel = new TextLabel();
			super(textLabel);
		}
		override protected function commitData(cause:IAdvice=null):void{
			textLabel.data = getDataProvider();
		}
		override protected function uncommitData(cause:IAdvice=null):void{
			textLabel.data = null;
		}
	}
}