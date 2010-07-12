package org.farmcode.display.progress
{
	import flash.display.DisplayObject;
	
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.nativeAssets.DisplayObjectAsset;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.core.LayoutView;
	
	public class AbstractProgressDisplay extends LayoutView implements IProgressDisplay
	{
		public function get measurable():Boolean{
			return _measurable;
		}
		public function set measurable(value:Boolean):void{
			if(_measurable!=value){
				_measurable = value;
				invalidate();
			}
		}
		
		public function get message():String{
			return _message;
		}
		public function set message(value:String):void{
			if(_message!=value){
				_message = value;
				invalidate();
			}
		}
		
		public function get progress():Number{
			return _progress;
		}
		public function set progress(value:Number):void{
			if(_progress!=value){
				_progress = value;
				validate(true);
			}
		}
		
		public function get total():Number{
			return _total;
		}
		public function set total(value:Number):void{
			if(_total!=value){
				_total = value;
				invalidate();
			}
		}
		
		public function get units():String{
			return _units;
		}
		public function set units(value:String):void{
			if(_units!=value){
				_units = value;
				invalidate();
			}
		}
		public function get display():IDisplayAsset{
			return asset;
		}
		public function get layoutView():ILayoutView{
			return this;
		}
		
		private var _units:String;
		private var _total:Number;
		private var _progress:Number;
		private var _message:String;
		private var _measurable:Boolean;
		
		public function AbstractProgressDisplay(asset:IDisplayAsset=null)
		{
			super(asset);
		}
	}
}