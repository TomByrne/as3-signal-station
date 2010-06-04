package org.farmcode.sodalityPlatformEngine.control.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.control.adviceTypes.IRemoveFocusOffsetItemsAdvice;
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;

	public class RemoveFocusOffsetItemsAdvice extends AbstractFocusOffsetItemsAdvice implements IRemoveFocusOffsetItemsAdvice
	{
		override public function get revertAdvice():Advice{
			return new AddFocusOffsetItemsAdvice(focusItem, focusOffsetItems);
		}
		
		public function RemoveFocusOffsetItemsAdvice(focusItem:IFocusItem=null, focusOffsetItems:Array=null)
		{
			super(focusItem, focusOffsetItems);
		}
		
	}
}