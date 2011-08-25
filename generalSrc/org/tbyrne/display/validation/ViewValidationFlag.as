package org.tbyrne.display.validation
{
	import flash.events.ErrorEvent;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.IView;


	
	public class ViewValidationFlag extends FrameValidationFlag
	{
		public static const WITH_ASSET_CHECKER:Function = function(from:ViewValidationFlag):Boolean{return from.asset!=null};
		
		
		
		/**
		 * @inheritDoc
		 */
		/*public function get assetChanged():IAct{
			if(!_assetChanged)_assetChanged = new Act();
			return _assetChanged;
		}*/
		
		public function get asset():IDisplayObject{
			return _asset;
		}
		public function get view():IView{
			return _view;
		}
		public function set view(value:IView):void{
			if(_view!=value){
				var oldView:IView = _view;
				if(_view){
					_view.assetChanged.removeHandler(onAssetChanged);
				}
				_view = value;
				if(_view){
					setAsset(_view.asset);
					_view.assetChanged.addHandler(onAssetChanged);
				}else{
					setAsset(null);
				}
			}
		}
		
		
		private var _view:IView;
		private var _asset:IDisplayObject;
		//protected var _assetChanged:Act;
		//protected var _allowAddWithoutAsset:Boolean;
		
		public function ViewValidationFlag(view:IView, validator:Function, valid:Boolean, parameters:Array=null, readyChecker:Function=null){
			if(readyChecker==null)readyChecker = WITH_ASSET_CHECKER;
			super(validator, valid, parameters, readyChecker);
			_manager = FrameValidationManager.instance;
			//_allowAddWithoutAsset = allowAddWithoutAsset;
			this.view = view;
			checkAdded();
		}
		
		
		protected function onAssetChanged(from:IView, oldAsset:IAsset):void{
			setAsset(_view.asset);
		}
		protected function setAsset(asset:IDisplayObject):void{
			if(_asset!=asset){
				
				if(_added){
					// remove before changing asset to allow manager to lookup by asset
					setAdded(false);
				}
				
				//var oldAsset:IDisplayObject = _asset;
				_asset = asset;
				
				
				/*
				dispatch event after removing now unadded flags to avoid manager handling event
				dispatch event before adding new added flags to avoid manager handling event
				if is added and remains so, only dispatch event (no add or remove)
				*/
				//if(_assetChanged)_assetChanged.perform(this,oldAsset);
				
				if(_asset){
					setAdded(true);
				}
			}
		}
		private function checkAdded():void{
			if(_asset || readyForExecution){
				setAdded(true);
			}else{
				setAdded(false);
			}
		}
		override public function release():void{
			super.release();
			this.view = null;
		}
		
		override public function isDescendant(child:IFrameValidationFlag):Boolean{
			CONFIG::debug{
				if(!_asset){
					Log.error("isDescendant shouldn't be called until an asset is set.");
				}
			}
			
			var viewFlag:ViewValidationFlag = (child as ViewValidationFlag);
			if(viewFlag && viewFlag.asset){
				var subject:IDisplayObject = viewFlag.asset.parent;
				while(subject && subject!=asset){
					subject = subject.parent;
				}
				return (subject!=null);
			}else{
				return false;
			}
		}
		override public function get hierarchyKey():*{
			CONFIG::debug{
				if(!_asset){
					Log.error("get hierarchyKey shouldn't be called until an asset is set.");
				}
			}
			
			return _asset;
		}
	}
}