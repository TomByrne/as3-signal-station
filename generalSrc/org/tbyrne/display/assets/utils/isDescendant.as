package org.tbyrne.display.assets.utils
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	/**
	 * Finds if the given descendant is within the given parent's display tree
	 * 
	 * @param	parent		The object's tree to search within
	 * @param	descendant	The object to search for within the tree
	 * 
	 * @return	true if the descendant was found in the parent's tree, false if not
	 */
	public function isDescendant(parent:IDisplayObjectContainer, decendant:IDisplayObject):Boolean{
		var subject:IDisplayObject = decendant;
		while(subject && subject!=decendant.stage){
			subject = subject.parent;
			if(subject==parent)return true;
		}
		return false;
	}
}