package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.NativeAct;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.IStageAsset;

	public class StageAsset extends DisplayObjectContainerAsset implements IStageAsset
	{
		/**
		 * @inheritDoc
		 */
		public function get resize():IAct{
			if(!_resize)_resize = new NativeAct(_stage,Event.RESIZE,[this]);
			return _resize;
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
				_focus = NativeAssetFactory.getNew(_stage.focus);
				return _focus;
			}else{
				return null;
			}
		}
		public function set focus(value:IInteractiveObjectAsset):void{
			if(_focus!=value){
				_focus = value as InteractiveObjectAsset;
				_stage.focus = _focus.displayObject as InteractiveObject;
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
		
		private var _stage:Stage;
		private var _focus:InteractiveObjectAsset;
		protected var _resize:NativeAct;
		
		public function StageAsset(){
			super();
		}
	}
}