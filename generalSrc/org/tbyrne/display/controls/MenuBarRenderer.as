package org.tbyrne.display.controls
{
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.assetTypes.IInteractiveObjectAsset;
	
	use namespace DisplayNamespace;
	
	public class MenuBarRenderer extends ListRenderer
	{
		public function MenuBarRenderer(asset:IDisplayAsset=null){
			super(asset);
			useDataForSelected = false;
		}
		override protected function onRollOver(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			super.onRollOver(from, info);
			if(_active && _selectedIndices && _selectedIndices.length){
				selected = true;
			}
		}
	}
}