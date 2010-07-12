package org.farmcode.display.core
{
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IStageAsset;
	
	public class ScopedObject extends View implements IScopedObject
	{
		protected var _addedChanged:Act;
		protected var _active:Boolean = true;
		protected var _assetStage:IStageAsset;
		protected var _added:Boolean;
		
		
		/**
		 * handler(from:ScopeDisplayObject)
		 */
		public function get addedChanged():IAct{
			if(!_addedChanged)_addedChanged = new Act();
			return _addedChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			return assetChanged;
		}
		
		
		
		public function set scope(value:IDisplayAsset):void{
			asset = value;
		}
		public function get scope():IDisplayAsset{
			return asset;
		}
		
		protected var _scopeChanged:Act;
		
		public function get added():Boolean{
			return _added;
		}
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_active != value){
				_active = value;
				checkAdded();
			}
		}
		override public function set asset(value:IDisplayAsset):void{
			if(_asset!=value){
				if(_asset){
					_asset.addedToStage.removeHandler(onAdded);
					_asset.removedFromStage.removeHandler(onRemoved);
				}
				super.asset = value;
				if(_asset){
					_asset.addedToStage.addHandler(onAdded);
					_asset.removedFromStage.addHandler(onRemoved);
					setStage(_asset.stage);
				}else{
					setStage(null);
				}
			}
		}
		protected function setStage(stage:IStageAsset):void{
			_assetStage = stage;
			checkAdded();
		}
		protected function onAdded(e:Event, from:IDisplayAsset):void{
			setStage(_asset.stage);
		}
		protected function onRemoved(e:Event, from:IDisplayAsset):void{
			setStage(null);
		}
		protected function checkAdded():void{
			var shouldAdd:Boolean = shouldAdd();
			if(shouldAdd){
				if(!_added){
					setAdded(true);
				}
			}else if(_added){
				setAdded(false);
			}
		}
		protected function setAdded(value:Boolean):void{
			_added = value;
			if(_addedChanged)_addedChanged.perform(this);
		}
		protected function shouldAdd():Boolean{
			return _active && _asset!=null && _assetStage;
		}
	}
}