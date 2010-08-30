package org.farmcode.display.core
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.farmcode.display.assets.assetTypes.ISpriteAsset;
	import org.farmcode.display.assets.states.StateDef;
	import org.farmcode.display.validation.FrameValidationFlag;
	
	public class DrawableView extends View implements IOutroView, IScopedObject
	{
		static private const OUTRO_FRAME_LABEL:String = "outro";
		static private const INTRO_FRAME_LABEL:String = "intro";
		
		override public function set asset(value:IDisplayAsset):void{
			if(_asset!=value){
				if(_asset){
					asset.addedToStage.removeHandler(onAddedToStage);
					asset.removedFromStage.removeHandler(onRemovedFromStage);
				}
				checkIsUnbound();
				var oldAsset:IAsset = _asset;
				super.asset = value;
				if(_asset){
					_containerAsset = (value as IContainerAsset);
					_spriteAsset = (value as ISpriteAsset);
					_interactiveObjectAsset = (value as IInteractiveObjectAsset);
					asset.addedToStage.addHandler(onAddedToStage);
					asset.removedFromStage.addHandler(onRemovedFromStage);
				}else{
					_containerAsset = null;
					_interactiveObjectAsset = null;
					_spriteAsset = null;
				}
				invalidate();
			}
		}
		public function get scope():IDisplayAsset{
			return asset;
		}
		public function set scope(value:IDisplayAsset):void{
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
		
		protected var _containerAsset:IContainerAsset;
		protected var _interactiveObjectAsset:IInteractiveObjectAsset;
		protected var _spriteAsset:ISpriteAsset;
		
		protected var _inited:Boolean;
		protected var _bound:Boolean;
		protected var _introShown:Boolean;
		protected var _outroShown:Boolean;
		protected var _playAssetLabelDelay:DelayedCall;
		private var _resetAnimationsDelay:DelayedCall;
		protected var _stateList:Array;
		protected var _drawFlag:FrameValidationFlag;
		protected var _revertParentStateLists:Boolean;
		
		private var _transState:StateDef = new StateDef([INTRO_FRAME_LABEL,OUTRO_FRAME_LABEL]);
		
		public function DrawableView(asset:IDisplayAsset=null){
			_drawFlag = new FrameValidationFlag(this,commitDraw,false);
			super(asset);
		}
		final protected function attemptInit() : void{
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
				if(_resetAnimationsDelay){
					_resetAnimationsDelay.clear();
				}
				_resetAnimationsDelay = new DelayedCall(resetAnimations,ret);
				_resetAnimationsDelay.begin()
				return ret;
			}
			return 0;
		}
		protected function doShowOutro():Number{
			_transState.temporarySelect(1);
			return _transState.stateChangeDuration;
		}
		protected function resetAnimations():void{
			_outroShown = false;
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
		protected function invalidate(): void{
			_drawFlag.invalidate();
		}
		
		/**
		 * @inheritDoc
		 */
		public function validate(forceDraw: Boolean = false): void{
			_drawFlag.validate(forceDraw);
		}
		
		/**
		 * @inheritDoc
		 */
		final public function commitDraw(): void{
			checkIsBound();
			if(asset)this.draw();
		}
		
		/**
		 * The draw method should be overridden within subclasses of the DelayedDrawSprite class, 
		 * it should contain all logic for visual layout and drawing. Conventionally, if the draw 
		 * method becomes very large, it will be broken down into several parts, with boolean flags 
		 * indicating which parts are invalid. This means that when <code>invalidate()</code> gets 
		 * called, the appropriate boolean will be flagged and the draw method will contain an 
		 * <code>if</code> statement testing that boolean, executing if the boolean is flagged, and			
		 * finally resetting the boolean.
		 */
		protected function draw():void{
			
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
			if(!_bound && _asset){
				_bound = true;
				bindToAsset();
				if(autoIntro())showIntro();
			}
		}
		protected function checkIsUnbound():void{
			if(_bound){
				unbindFromAsset();
				_bound = false;
				invalidate();
			}
		}
		protected function onAddedToStage(from:IAsset):void{
			validate();
			if(autoIntro())showIntro();
		}
		protected function onRemovedFromStage(from:IAsset):void{
			_introShown = false;
			_outroShown = false;
		}
		protected function fillStateList(fill:Array):Array{
			fill.push(_transState);
			return fill;
		}
	}
}