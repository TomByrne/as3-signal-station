package org.farmcode.display.assets.nativeAssets
{
	import org.farmcode.display.assets.AbstractAsset;
	import org.farmcode.display.assets.IAssetFactory;
	
	public class NativeAsset extends AbstractAsset
	{
		internal function get display():*{
			// override me
		}
		internal function set display(value:*):void{
			// override me
		}
		
		
		override public function set factory(value:IAssetFactory):void{
			_factory = value;
			var cast:NativeAssetFactory = (value as NativeAssetFactory);
			if(cast)_nativeFactory = cast;
		}
		
		
		protected var _nativeFactory:NativeAssetFactory;
		
		public function NativeAsset(factory:IAssetFactory){
			super(factory);
		}
	}
}