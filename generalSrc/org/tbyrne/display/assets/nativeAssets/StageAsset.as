package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.NativeAct;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.IStage;

	public class StageAsset extends DisplayObjectContainerAsset implements IStage
	{
		/**
		 * @inheritDoc
		 */
		public function get resize():IAct{
			if(!_resize)_resize = new NativeAct(_stage,Event.RESIZE,[this],false);
			return _resize;
		}
		/**
		 * @inheritDoc
		 */
		public function get fullScreen():IAct{
			if(!_fullScreen)_fullScreen = new NativeAct(_stage,FullScreenEvent.FULL_SCREEN,[this],false);
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
		
		public function get focus():IInteractiveObject{
			if(_focus && _focus.displayObject==_stage.focus){
				return _focus;
			}else if(_stage.focus){
				_focus = _nativeFactory.getNew(_stage.focus);
				return _focus;
			}else{
				return null;
			}
		}
		public function set focus(value:IInteractiveObject):void{
			if(focus!=value){ // must use getter to validate 
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
		
		PLATFORM::air{
			
		public function get nativeWindow():NativeWindow {
			return _stage.nativeWindow;
		}
		
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