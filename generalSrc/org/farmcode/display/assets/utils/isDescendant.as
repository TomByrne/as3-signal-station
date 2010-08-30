package org.farmcode.display.assets.utils
{
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;

	/**
	 * Finds if the given descendant is within the given parent's display tree
	 * 
	 * @param	parent		The object's tree to search within
	 * @param	descendant	The object to search for within the tree
	 * 
	 * @return	true if the descendant was found in the parent's tree, false if not
	 */
	public function isDescendant(parent:IContainerAsset, decendant:IDisplayAsset):Boolean{
		var subject:IDisplayAsset = decendant;
		while(subject!=decendant.stage){
			subject = subject.parent;
			if(subject==parent)return true;
		}
		return false;
	}
}