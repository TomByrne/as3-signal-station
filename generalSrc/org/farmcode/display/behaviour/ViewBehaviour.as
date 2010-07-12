package org.farmcode.display.behaviour
{
	import au.com.thefarmdigital.delayedDraw.DelayedDrawer;
	import au.com.thefarmdigital.delayedDraw.IDrawable;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.ISelfAnimatingView;
	import org.farmcode.display.utils.MovieClipUtils;
	import org.farmcode.memory.LooseReference;
	
	public class ViewBehaviour extends EventDispatcher implements IDrawable, IViewBehaviour, ISelfAnimatingView
	{
		static private const OUTRO_FRAME_LABEL:String = "outro";
		static private const INTRO_FRAME_LABEL:String = "intro";
		
		public function get asset():DisplayObject{
			return _asset;
		}
		public function set asset(value:DisplayObject):void{
			if(_asset!=value){
				if(_asset){
					_asset.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					_asset.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
				}
				checkIsUnbound();
				var oldAsset:DisplayObject = _asset;
				_asset = value;
				if(_asset){
					_containerAsset = (value as DisplayObjectContainer);
					_spriteAsset = (value as Sprite);
					_movieClipAsset = (value as MovieClip);
					
					checkAssetType();
					_asset.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage,false,0,true);
					_asset.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage,false,0,true);
				}
				if(_assetChanged)_assetChanged.perform(this,oldAsset);
				invalidate();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get assetChanged():IAct{
			if(!_assetChanged)_assetChanged = new Act();
			return _assetChanged;
		}
		
		/**
		 * When the asset property is set, a cast version (as DisplayObjectContainer) is
		 * stored to avoid constant recasting. If a ViewBehaviour depends on it's asset being
		 * a DisplayObjectContainer (or some other class) the assetType property can be
		 * set, this will throw an error if an asset of a different type is set.
		 */
		public function get containerAsset():DisplayObjectContainer{
			return _containerAsset;
		}
		public function get assetType():Class{
			return _assetType;
		}
		public function set assetType(value:Class):void{
			if(_assetType!=value){
				_assetType = value;
				checkAssetType();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get drawDisplay():DisplayObject{
			return _asset;
		}
		public function get readyForDraw():Boolean{
			return _asset && _asset.stage;
		}
		
		private var _asset:DisplayObject;
		private var _containerAsset:DisplayObjectContainer;
		private var _assetType:Class;
		protected var _bound:Boolean;
		protected var _movieClipAsset:MovieClip;
		protected var _spriteAsset:Sprite;
		protected var _introShown:Boolean;
		protected var _outroShown:Boolean;
		protected var _playAssetLabelDelay:DelayedCall;
		private var _resetAnimationsDelay:DelayedCall;
		private var _lastStage:LooseReference = new LooseReference();
		protected var _assetChanged:Act;
		
		public function ViewBehaviour(asset:DisplayObject=null){
			super();
			this.asset = asset;
		}
		protected function autoIntro():Boolean{
			return true;
		}
		public final function showIntro():void{
			if(asset && asset.stage && !_introShown){
				_introShown = true;
				doShowIntro();
			}
		}
		protected function doShowIntro():void{
			playAssetFrameLabel(INTRO_FRAME_LABEL);
		}
		public final function showOutro():Number{
			if(asset.stage && _introShown){
				_outroShown = true;
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
			return playAssetFrameLabel(OUTRO_FRAME_LABEL);
		}
		protected function resetAnimations():void{
			_introShown = false;
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
			if(_asset)DelayedDrawer.changeValidity(this, false);
		}
		
		/**
		 * @inheritDoc
		 */
		public function validate(forceDraw: Boolean = false): void{
			if(forceDraw)invalidate();
			DelayedDrawer.doDraw(this);
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
		protected function draw():void
		{
			
		}
		protected function bindToAsset():void
		{
			
		}
		protected function unbindFromAsset():void
		{
			
		}
		protected function checkAssetType():void{
			if(_assetType && _asset && !(_asset is _assetType)){
				throw new Error("Asset "+_asset+" doesn't match assetType "+_assetType);
			}
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
		protected function onAddedToStage(e:Event):void{
			validate();
			if(autoIntro())showIntro();
			_lastStage.object = asset.stage;
		}
		protected function onRemovedFromStage(e:Event):void{
			_introShown = false;
			_outroShown = false;
		}
		
		protected function playAssetFrameLabel(frameLabel:String):Number{
			var stage:Stage = asset.stage;
			if(!stage){
				stage = _lastStage.reference as Stage;
			}
			if(_movieClipAsset && stage){
				var duration:int = MovieClipUtils.playFrameLabel(_movieClipAsset,frameLabel);
				if(duration!=-1){
					return (duration/stage.frameRate);
				}
			}
			return 0;
		}
	}
}