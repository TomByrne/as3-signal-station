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
				if(_display){
					_x = _display.x;
					_y = _display.y;
					_width = _display.width;
					_height = _display.height;
					_xSet = false;
					_ySet = false;
					_widthSet = false;
					_heightSet = false;
				}
			}
		}
		
		
		override public function set factory(value:IAssetFactory):void{
			_factory = value;
			var cast:NativeAssetFactory = (value as NativeAssetFactory);
			if(cast)_nativeFactory = cast;
		}
		
		
		public function get noFilters():Boolean{
			return _noFilters;
		}
		public function set noFilters(value:Boolean):void{
			if(_noFilters!=value){
				_noFilters = value;
			}
		}
		
		public function get pixelSnapping():Boolean{
			return _pixelSnapping;
		}
		public function set pixelSnapping(value:Boolean):void{
			if(_pixelSnapping!=value){
				_pixelSnapping = value;
				setPixelX();
				setPixelY();
				setPixelWidth();
				setPixelHeight();
			}
		}
		public function set x(value:Number):void {
			_x = value;
			_xSet = true;
			if(pixelSnapping){
				setPixelX();
				setPixelWidth();
			}else{
				_display.x = value;
			}
		}
		
		
		public function get x():Number {
			return _x;
		}
		public function set y(value:Number):void {
			_y = value;
			_ySet = true;
			if(pixelSnapping){
				setPixelY();
				setPixelHeight();
			}else{
				_display.y = value;
			}
		}
		public function get y():Number {
			return _y;
		}
		public function set height(value:Number):void {
			_height = value;
			_heightSet = true;
			if(_pixelSnapping){
				setPixelHeight();
			}else{
				_display.height = value;
			}
		}
		
		
		
		public function get height():Number {
			return _height;
		}
		public function set width(value:Number):void {
			_width = value;
			_widthSet = true;
			if(_pixelSnapping){
				setPixelWidth();
			}else{
				_display.width = value;
			}
		}
		
		
		public function get width():Number {
			return _width;
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
		
		protected var _x:Number;
		protected var _y:Number;
		protected var _width:Number;
		protected var _height:Number;
		protected var _xSet:Boolean;
		protected var _ySet:Boolean;
		protected var _widthSet:Boolean;
		protected var _heightSet:Boolean;
		
		protected var _noFilters:Boolean;
		protected var _pixelSnapping:Boolean;
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
		private function setPixelX():void{
			if(_xSet){
				_display.x = round(_x);
			}
		}
		private function setPixelY():void{
			if(_ySet){
				_display.y = round(_y);
			}
		}
		protected function setPixelWidth():void{
			if(_widthSet){
				if(_width%1){
					var right:Number = round(_x+_width);
					_display.width = right-_display.x;
				}else{
					_display.width = _width;
				}
			}
		}
		protected function setPixelHeight():void{
			if(_heightSet){
				if(_height%1){
					var bottom:Number = round(_y+_height);
					_display.height = bottom-_display.y;
				}else{
					_display.height = _height;
				}
			}
		}
		
		protected function round(value:Number): int{
			return value%1 ? (value>0?int(value+0.5) : int(value-0.5)) :value;
		}
	}
}