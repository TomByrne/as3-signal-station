package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.NativeAct;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.farmcode.display.assets.assetTypes.IStageAsset;

	public class StageAsset extends DisplayObjectContainerAsset implements IStageAsset
	{
		/**
		 * @inheritDoc
		 */
		public function get resize():IAct{
			if(!_resize)_resize = new NativeAct(_stage,Event.RESIZE,[this]);
			return _resize;
		}
		/**
		 * @inheritDoc
		 */
		public function get fullScreen():IAct{
			if(!_fullScreen)_fullScreen = new NativeAct(_stage,FullScreenEvent.FULL_SCREEN,[this]);
			return _fullScreen;
		}
		
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				super.displayObject = value;
				if(value){
					_stage = value as Stage;
				}else{
					_stage = null;
				}
				if(_resize)_resize.eventDispatcher = value;
			}
		}
		
		public function get focus():IInteractiveObjectAsset{
			if(_focus && _focus.displayObject==_stage.focus){
				return _focus;
			}else if(_stage.focus){
				_focus = _nativeFactory.getNew(_stage.focus);
				return _focus;
			}else{
				return null;
			}
		}
		public function set focus(value:IInteractiveObjectAsset):void{
			if(_focus!=value){
				_focus = value as InteractiveObjectAsset;
				_stage.focus = _focus?(_focus.displayObject as InteractiveObject):null;
			}
		}
		public function get stageWidth():Number{
			return _stage.stageWidth;
		}
		public function get stageHeight():Number{
			return _stage.stageHeight;
		}
		public function get frameRate():Number{
			return _stage.frameRate;
		}
		public function get displayState():String{
			return _stage.displayState;
		}
		public function set displayState(value:String):void{
			_stage.displayState = value;
		}
		public function get loaderInfo():LoaderInfo{
			return _stage.loaderInfo;
		}
		
		private var _stage:Stage;
		private var _focus:InteractiveObjectAsset;
		protected var _resize:NativeAct;
		protected var _fullScreen:NativeAct;
		
		public function StageAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
	}
}