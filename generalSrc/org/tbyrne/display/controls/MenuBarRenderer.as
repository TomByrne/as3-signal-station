package org.tbyrne.display.controls
{
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.tbyrne.display.containers.ICascadingMenuBarRenderer;
	
	use namespace DisplayNamespace;
	
	public class MenuBarRenderer extends ListRenderer implements ICascadingMenuBarRenderer
	{
		
		public function get isMenuOpen():Boolean{
			return _isMenuOpen;
		}
		public function set isMenuOpen(value:Boolean):void{
			if(_isMenuOpen!=value){
				_isMenuOpen = value;
			}
		}
		
		private var _isMenuOpen:Boolean;
		
		
		public function MenuBarRenderer(asset:IDisplayAsset=null){
			super(asset);
			useDataForSelected = false;
		}
		override protected function onRollOver(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			super.onRollOver(from, info);
			if(_isMenuOpen && _active){
				selected = true;
			}
		}
	}
}