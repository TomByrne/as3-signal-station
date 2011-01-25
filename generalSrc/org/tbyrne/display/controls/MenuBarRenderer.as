package org.tbyrne.display.controls
{
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
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
		
		
		public function MenuBarRenderer(asset:IDisplayObject=null){
			super(asset);
			useDataForSelected = false;
		}
		override protected function onRollOver(from:IInteractiveObject, info:IMouseActInfo):void{
			super.onRollOver(from, info);
			if(_isMenuOpen && _active){
				selected = true;
			}
		}
	}
}