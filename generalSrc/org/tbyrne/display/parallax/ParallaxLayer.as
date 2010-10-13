package org.tbyrne.display.parallax
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	public class ParallaxLayer extends ParallaxDisplay
	{
		override public function set display(value:DisplayObject) : void{
			super.display = value;
			_layerContainer = (value as DisplayObjectContainer);
		}
		
		public function get layerContainer():DisplayObjectContainer{
			return _layerContainer;
		}
		
		public function get parallaxChildren():Array{
			return _parallaxChildren;
		}
		
		private var _parallaxChildren:Array = [];
		private var _layerContainer:DisplayObjectContainer;
		
		public function ParallaxLayer(){
			display = new Sprite();
			position = new Point3D();
			cacheAsBitmap = false;
		}
		public function addParallaxChild(child:IParallaxDisplay):void{
			child.parallaxParent = this;
			_parallaxChildren.push(child);
		}
		public function removeParallaxChild(child:IParallaxDisplay):void{
			if(child.parallaxParent==this){
				var index:Number = _parallaxChildren.indexOf(child);
				_parallaxChildren.splice(index,1);
				child.parallaxParent = null;
			}
		}
		public function removeAllParallaxChildren():void{
			for each(var child:IParallaxDisplay in _parallaxChildren){
				child.parallaxParent = null;
			}
			_parallaxChildren = [];
		}
	}
}