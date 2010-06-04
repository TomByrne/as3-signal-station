package org.farmcode.sodalityPlatformEngine.control.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IAddFocusOffsetItemsAdvice;
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;
	
	public class AddFocusOffsetItemsAdvice extends AbstractFocusOffsetItemsAdvice implements IAddFocusOffsetItemsAdvice
	{
		override public function get revertAdvice():Advice{
			return new RemoveFocusOffsetItemsAdvice(focusItem, focusOffsetItems);
		}
		
		public function AddFocusOffsetItemsAdvice(focusItem:IFocusItem=null, focusOffsetItems:Array=null)
		{
			super(focusItem, focusOffsetItems);
		}
		
	}
}