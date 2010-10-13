package org.tbyrne.display.core
{
	import flash.events.Event;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.assetTypes.IStageAsset;
	
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
		
		
		public function ScopedObject(asset:IDisplayAsset=null){
			super(asset);
		}
		protected function setStage(stage:IStageAsset):void{
			_assetStage = stage;
			checkAdded();
		}
		protected function onAdded(from:IDisplayAsset):void{
			/*
			This conditional is here because if the asset property gets
			set to null during a another handler of the addedToStage
			Act, then this handler will still be called (handlers
			aren't removed till after the whole perform call).
			 */
			if(_asset){
				setStage(_asset.stage);
			}
		}
		protected function onRemoved(from:IDisplayAsset):void{
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