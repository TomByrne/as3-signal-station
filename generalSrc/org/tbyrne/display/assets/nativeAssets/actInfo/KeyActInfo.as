package org.tbyrne.display.assets.nativeAssets.actInfo
{
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	
	public class KeyActInfo implements IKeyActInfo
	{
		
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
			if(_ctrlKey!=value){
				_ctrlKey = value;
			}
		}
		
		public function get shiftKey():Boolean{
			return _shiftKey;
		}
		public function set shiftKey(value:Boolean):void{
			_shiftKey = value;
		}
		
		public function get keyLocation():uint{
			return _keyLocation;
		}
		public function set keyLocation(value:uint):void{
			_keyLocation = value;
		}
		
		public function get keyCode():uint{
			return _keyCode;
		}
		public function set keyCode(value:uint):void{
			_keyCode = value;
		}
		
		public function get charCode():uint{
			return _charCode;
		}
		public function set charCode(value:uint):void{
			_charCode = value;
		}
		
		public function get keyTarget():IDisplayAsset{
			return _keyTarget;
		}
		public function set keyTarget(value:IDisplayAsset):void{
			_keyTarget = value;
		}
		
		private var _keyTarget:IDisplayAsset;
		private var _shiftKey:Boolean;
		private var _ctrlKey:Boolean;
		private var _altKey:Boolean;
		
		private var _charCode:uint;
		private var _keyCode:uint;
		private var _keyLocation:uint;
		
		
		public function KeyActInfo(keyTarget:IDisplayAsset, altKey:Boolean, ctrlKey:Boolean, shiftKey:Boolean, charCode:uint, keyCode:uint, keyLocation:uint){
			this.keyTarget = keyTarget;
			this.charCode = charCode;
			this.keyCode = keyCode;
			this.keyLocation = keyLocation;
			this.shiftKey = shiftKey;
			this.ctrlKey = ctrlKey;
			this.altKey = altKey;
		}
	}
}