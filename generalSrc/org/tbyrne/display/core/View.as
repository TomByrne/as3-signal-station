package org.tbyrne.display.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public class View implements IView
	{
		/**
		 * @inheritDoc
		 */
		public function get assetChanged():IAct{
			if(!_assetChanged)_assetChanged = new Act();
			return _assetChanged;
		}
		public function get asset():IDisplayObject{
			return _asset;
		}
		public function set asset(value:IDisplayObject):void{
			if(_asset!=value){
				var oldAsset:IDisplayObject = _asset;
				_asset = value;
				if(_assetChanged)_assetChanged.perform(this,oldAsset);
			}
		}
		
		protected var _asset:IDisplayObject;
		protected var _assetChanged:Act;
		
		public function View(asset:IDisplayObject=null){
			this.asset = asset;
		}
		
		
	}
}