package org.tbyrne.shortcuts
{
	import org.tbyrne.input.shortcuts.IShortcutInputItem;

	public interface IShortcutMediator
	{
		function addShortcut(shortcut:IShortcutInputItem):void;
		function removeShortcut(shortcut:IShortcutInputItem):void;
	}
}