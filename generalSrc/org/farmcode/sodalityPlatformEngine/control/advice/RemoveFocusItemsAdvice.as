package org.farmcode.sodalityPlatformEngine.control.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IRemoveFocusItemsAdvice;

	public class RemoveFocusItemsAdvice extends AbstractFocusItemsAdvice implements IRemoveFocusItemsAdvice
	{
		override public function get revertAdvice():Advice{
			return new AddFocusItemsAdvice(focusItems, doSnapFocus);
		}
		
		public function RemoveFocusItemsAdvice(focusItems:Array=null, doSnapFocus:Boolean = false){
			super(focusItems, doSnapFocus);
		}
		
	}
}