package org.tbyrne.display.assets.nativeAssets
{
	import org.tbyrne.display.assets.AbstractAsset;
	import org.tbyrne.display.assets.IAssetFactory;
	import org.tbyrne.display.assets.assetTypes.IBaseDisplayAsset;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	
	public class NativeAsset extends AbstractAsset implements IBaseDisplayAsset
	{
		internal function get display():*{
			return _display;
		}
		internal function set display(value:*):void{
			if(_display!=value){
				_display = value;
			}
		}
		
		
		override public function set factory(value:IAssetFactory):void{
			_factory = value;
			var cast:NativeAssetFactory = (value as NativeAssetFactory);
			if(cast)_nativeFactory = cast;
		}
		
		
		public function get pixelSnapping():Boolean{
			return _pixelSnapping;
		}
		public function set pixelSnapping(value:Boolean):void{
			if(_pixelSnapping!=value){
				_pixelSnapping = value;
			}
		}
		public function set x(value:Number):void {
			if(pixelSnapping){
				_display.x = int(value+0.5);
			}else{
				_display.x = value;
			}
		}
		public function get x():Number {
			return _display.x;
		}
		public function set y(value:Number):void {
			if(pixelSnapping){
				_display.y = int(value+0.5);
			}else{
				_display.y = value;
			}
		}
		public function get y():Number {
			return _display.y;
		}
		public function set height(value:Number):void {
			if(pixelSnapping)value = int(value+0.5);
			_display.height = value;
		}
		
		
		public function get height():Number {
			return _display.height;
		}
		public function set width(value:Number):void {
			if(pixelSnapping)value = int(value+0.5);
			_display.width = value;
		}
		public function get width():Number {
			return _display.width;
		}
		public function get stage():IStage {
			if(_isAddedToStage && !_stageAsset){
				_stageAsset = findStageRef();
			}
			return _stageAsset;
		}
		
		
		public function set visible(value:Boolean):void {
			_display.visible = value;
		}
		public function get visible():Boolean {
			return _display.visible;
		}
		
		private var _display:*;
		private var _pixelSnapping:Boolean;
		protected var _stageAsset:IStage;
		protected var _nativeFactory:NativeAssetFactory;
		
		protected var _isAddedToStage:Boolean;
		
		public function NativeAsset(factory:IAssetFactory){
			super(factory);
		}
		protected function findStageRef():IStage{
			var thisStage:IStage = (this as IStage);
			if(thisStage){
				return thisStage;
			}else{
				return _nativeFactory.getNew(_display.stage);
			}
		}
	}
}