package org.tbyrne.display.core
{
	public interface IScopedObjectRoot extends IScopedObject
	{
		function addDescendant(descendant:IScopedObject):void;
		function removeDescendant(descendant:IScopedObject):void;
	}
}