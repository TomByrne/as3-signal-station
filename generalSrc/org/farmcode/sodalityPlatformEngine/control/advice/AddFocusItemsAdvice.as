package org.farmcode.sodalityPlatformEngine.control.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IAddFocusItemsAdvice;

	public class AddFocusItemsAdvice extends AbstractFocusItemsAdvice implements IAddFocusItemsAdvice
	{
		override public function get revertAdvice():Advice{
			return new RemoveFocusItemsAdvice(focusItems, doSnapFocus);
		}
		
		public function AddFocusItemsAdvice(focusItems:Array=null, doSnapFocus:Boolean = false){
			super(focusItems, doSnapFocus);
		}
		
	}
}