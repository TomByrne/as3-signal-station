package org.tbyrne.display.validation
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.IView;


	/** FrameValidationFlag builds on ValidationFlag by making it
	 * validate onEnterFrame. FrameValidationFlags are placed into
	 * a heirarchy based on their scope property. When a 
	 * FrameValidationFlag gets validated (or forced to validate)
	 * it's children too get validated (if they're invalid).
	 */
	
	public class FrameValidationFlag extends ValidationFlag implements IFrameValidationFlag
	{
		/**
		 * @inheritDoc
		 */
		public function get assetChanged():IAct{
			if(!_assetChanged)_assetChanged = new Act();
			return _assetChanged;
		}
		
		public function get asset():IDisplayAsset{
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
		public function get readyForExecution():Boolean{
			return true;
		}
		
		
		private var _view:IView;
		private var _asset:IDisplayAsset;
		protected var _assetChanged:Act;
		protected var _added:Boolean;
		protected var _manager:FrameValidationManager;
		
		public function FrameValidationFlag(view:IView, validator:Function, valid:Boolean, parameters:Array=null){
			super(validator, valid, parameters);
			_manager = FrameValidationManager.instance;
			this.view = view;
			
		}
		protected function onAssetChanged(from:IView, oldAsset:IAsset):void{
			setAsset(_view.asset);
		}
		protected function setAsset(asset:IDisplayAsset):void{
			if(_asset!=asset){
				var oldAsset:IDisplayAsset = _asset;
				_asset = asset;
				if(_assetChanged)_assetChanged.perform(this,oldAsset);
				if(_asset){
					setAdded(true);
				}else{
					setAdded(false);
				}
			}
		}
		protected function setAdded(value:Boolean):void{
			if(_added!=value){
				_added = value;
				if(value){
					_manager.addFrameValFlag(this);
				}else{
					_manager.removeFrameValFlag(this);
				}
			}
		}
		override public function validate(force:Boolean=false):void{
			if(force || !_valid){
				if(_valid)invalidate();
				_manager.validate(this);
			}
		}
		public function execute():void{
			_valid = true;
			if(parameters)_validator.apply(null,parameters);
			else _validator();
		}
		override public function release():void{
			super.release();
			this.view = null;
		}
	}
}