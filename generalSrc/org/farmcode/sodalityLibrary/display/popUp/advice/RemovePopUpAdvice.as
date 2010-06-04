package org.farmcode.sodalityLibrary.display.popUp.advice
{
	import flash.display.DisplayObject;
	
	import org.farmcode.sodalityLibrary.display.popUp.adviceTypes.IRemovePopUpAdvice;

	public class RemovePopUpAdvice extends AbstractPopUpAdvice implements IRemovePopUpAdvice
	{
		public function RemovePopUpAdvice(displayPath:String=null, display:DisplayObject=null){
			super(displayPath,display);
		}
	}
}