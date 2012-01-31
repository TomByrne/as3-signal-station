package org.tbyrne.display.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.core.DelayedCall;
	import org.tbyrne.core.EnterFrameHook;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.ISprite;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.validation.ValidationFlag;
	import org.tbyrne.display.validation.ViewValidationFlag;
	
	public class DrawableView extends View implements IOutroView, IScopedObject
	{
		static private const OUTRO_FRAME_LABEL:String = "outro";
		static private const INTRO_FRAME_LABEL:String = "intro";
		
		override public function set asset(value:IDisplayObject):void{
			if(_asset!=value){
				if(_asset){
					asset.addedToStage.removeHandler(onAddedToStage);
					asset.removedFromStage.removeHandler(onRemovedFromStage);
					if(_asset.stage){
						onRemovedFromStage();
					}
				}
				checkIsUnbound();
				if(value){
					_containerAsset = (value as IDisplayObjectContainer);
					_spriteAsset = (value as ISprite);
					_interactiveObjectAsset = (value as IInteractiveObject);
				}else{
					_containerAsset = null;
					_interactiveObjectAsset = null;
					_spriteAsset = null;
				}
				_bindFlag.invalidate();
				super.asset = value;
				_bindFlag.validate();// don't force validation as setting the asset can sometimes cause binding
				if(value){
					value.addedToStage.addHandler(onAddedToStage);
					value.removedFromStage.addHandler(onRemovedFromStage);
					if(value.stage){
						onAddedToStage();
					}
				}
				invalidateAll();
			}
		}
		public function get scope():IDisplayObject{
			return asset;
		}
		public function set scope(value:IDisplayObject):void{
			asset = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			return assetChanged;
		}
		
		
		public function get readyForDraw():Boolean{
			return asset && asset.stage;
		}
		
		protected var _containerAsset:IDisplayObjectContainer;
		protected var _interactiveObjectAsset:IInteractiveObject;
		protected var _spriteAsset:ISprite;
		
		protected var _inited:Boolean;
		//protected var _bound:Boolean;
		protected var _introShown:Boolean;
		protected var _outroShown:Boolean;
		protected var _playAssetLabelDelay:DelayedCall;
		private var _finaliseOutroDelay:DelayedCall;
		protected var _stateList:Array;
		protected var _revertParentStateLists:Boolean;
		
		protected var _bindFlag:ValidationFlag;
		
		protected var _childDrawFlags:Vector.<ViewValidationFlag>;
		
		private var _transState:StateDef = new StateDef([INTRO_FRAME_LABEL,OUTRO_FRAME_LABEL]);
		
		public function DrawableView(asset:IDisplayObject=null){
			var _this:DrawableView = this;
			_bindFlag = new ValidationFlag(commitBound,false,null,function(from:ValidationFlag):Boolean{return _this.asset!=null});
			super(asset);
		}
		protected function addDrawFlag(frameValidationFlag:ViewValidationFlag):void{
			if(!_childDrawFlags)_childDrawFlags = new Vector.<ViewValidationFlag>();
			_childDrawFlags.push(frameValidationFlag);
		}
		
		protected function attemptInit() : void{
			if(!_inited){
				_inited = true;
				init();
			}
		}
		protected function init():void{
			_stateList = fillStateList([]);
		}
		protected function autoIntro():Boolean{
			return true;
		}
		public final function showIntro():void{
			if(asset && asset.stage && !_introShown){
				if(_finaliseOutroDelay){
					_finaliseOutroDelay.clear();
					finaliseOutro();
				}
				_introShown = true;
				_outroShown = false;
				doShowIntro();
			}
		}
		protected function doShowIntro():void{
			_transState.temporarySelect(0);
		}
		public final function showOutro():Number{
			if(asset && asset.stage && _introShown){
				_outroShown = true;
				_introShown = false;
				var ret:Number = doShowOutro();
				if(_finaliseOutroDelay){
					_finaliseOutroDelay.clear();
				}
				_finaliseOutroDelay = new DelayedCall(finaliseOutro,ret);
				_finaliseOutroDelay.begin()
				return ret;
			}
			return 0;
		}
		protected function doShowOutro():Number{
			_transState.temporarySelect(1);
			return _transState.stateChangeDuration;
		}
		protected function finaliseOutro():void{
			_outroShown = false;
			_finaliseOutroDelay = null;
		}
		
		/**
		 * The invalidate method flags this view to be redrawn on the next frame. It should be 
		 * called instead of calling <code>draw()</code> directly, meaning that if multiple visual 
		 * properties change, the (usually processor heavy) draw method only gets called once. There 
		 * will be a one frame delay between calling invalidate and the draw method being called, if 
		 * you want to call draw immediately, see the validate method.
		 * 
		 * @see validate
		 */
		protected function invalidateAll(): void{
			for each(var frameValidationFlag:ViewValidationFlag in _childDrawFlags){
				frameValidationFlag.invalidate();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function validate(forceDraw: Boolean = false): void{
			_bindFlag.validate();
			for each(var frameValidationFlag:ViewValidationFlag in _childDrawFlags){
				frameValidationFlag.validate(forceDraw);
			}
		}
		
		protected function bindToAsset():void{
			attemptInit();
			_revertParentStateLists = _asset.useParentStateLists;
			_asset.useParentStateLists = false;
			_asset.addStateList(_stateList,false);
		}
		protected function unbindFromAsset():void{
			_asset.removeStateList(_stateList);
			_asset.useParentStateLists = _revertParentStateLists;
		}
		protected function checkIsBound():void{
			_bindFlag.validate();
		}
		protected function get isBound():Boolean{
			return (_asset && (_bindFlag.valid || _bindFlag.validating));
		}
		protected function checkIsUnbound():void{
			if(_asset && _bindFlag.valid){
				unbindFromAsset();
			}
		}
		protected function commitBound():void{
			attemptInit();
			bindToAsset();
			validate();
		}
		protected function onAddedToStage(from:IAsset=null):void{
			EnterFrameHook.getAct().removeHandler(onFrameAfterRemove);
			if(_bindFlag.valid){
				validate();
			}else{
				_asset.exitFrame.addTempHandler(onFirstFrameExit);
			}
			if(autoIntro())showIntro();
		}
		
		protected function onFirstFrameExit(from:IAsset):void{
			validate();
		}
		
		protected function onRemovedFromStage(from:IAsset=null):void{
			EnterFrameHook.getAct().addTempHandler(onFrameAfterRemove);
		}
		
		private function onFrameAfterRemove():void{
			_introShown = false;
			_outroShown = false;
		}
		protected function fillStateList(fill:Array):Array{
			fill.push(_transState);
			return fill;
		}
	}
}