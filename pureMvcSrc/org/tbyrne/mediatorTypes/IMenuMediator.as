package org.tbyrne.mediatorTypes
{
	import org.tbyrne.input.menu.IMenuInputItem;

	public interface IMenuMediator
	{
		function addMenuItem(menuItem:IMenuInputItem):void;
		function removeMenuItem(menuItem:IMenuInputItem):void;
	}
}