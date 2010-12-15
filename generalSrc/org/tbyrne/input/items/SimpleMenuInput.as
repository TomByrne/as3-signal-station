package org.tbyrne.input.items
{
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.input.menu.IMenuInputItem;
	
	public class SimpleMenuInput extends AbstractInputItem implements IMenuInputItem
	{
		public function SimpleMenuInput(stringProvider:IStringProvider=null, scopedObject:IScopedObject=null)
		{
			super(stringProvider, scopedObject);
		}
	}
}