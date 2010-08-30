package org.farmcode.display.assets.nativeAssets.actInfo
{
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	
	public class MouseActInfo implements IMouseActInfo
	{
		public function get mouseTarget():IDisplayAsset{
			return _mouseTarget;
		}
		public function set mouseTarget(value:IDisplayAsset):void{
			_mouseTarget = value;
		}
		
		public function get altKey():Boolean{
			return _altKey;
		}
		public function set altKey(value:Boolean):void{
			_altKey = value;
		}
		
		public function get ctrlKey():Boolean{
			return _ctrlKey;
		}
		public function set ctrlKey(value:Boolean):void{
			_ctrlKey = value;
		}
		
		public function get shiftKey():Boolean{
			return _shiftKey;
		}
		public function set shiftKey(value:Boolean):void{
			_shiftKey = value;
		}
		
		private var _shiftKey:Boolean;
		private var _ctrlKey:Boolean;
		private var _altKey:Boolean;
		private var _mouseTarget:IDisplayAsset;
		
		public function MouseActInfo(mouseTarget:IDisplayAsset, altKey:Boolean, ctrlKey:Boolean, shiftKey:Boolean){
			this.mouseTarget = mouseTarget;
			this.altKey = altKey;
			this.ctrlKey = ctrlKey;
			this.shiftKey = shiftKey;
		}
	}
}