package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.display2D.types.ILayeredDisplayTrait;
	
	public class LayeredDisplayTrait extends DisplayObjectContainerTrait implements ILayeredDisplayTrait
	{
		
		/**
		 * handler(from:LayeredDisplayTrait)
		 */
		public function get visibleChanged():IAct{
			return (_visibleChanged || (_visibleChanged = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requestRedraw():IAct{
			return (_requestRedraw || (_requestRedraw = new Act()));
		}
		
		protected var _requestRedraw:Act;
		protected var _visibleChanged:Act;
		
		
		public function get layerId():String{
			return _layerId;
		}
		
		public function get visible():Boolean{
			return _visible;
		}
		public function set visible(value:Boolean):void{
			if(_visible!=value){
				_visible = value;
				if(_visibleChanged)_visibleChanged.perform(this);
				checkVisibility();
			}
		}
		public function get addChildren():Boolean{
			return _addChildren;
		}
		public function set addChildren(value:Boolean):void{
			_addChildren = value;
		}
		
		override public function set displayObject(value:DisplayObject):void{
			super.displayObject = value;
			checkVisibility();
		}
		
		protected var _visible:Boolean = true;
		protected var _layerId:String;
		
		
		public function LayeredDisplayTrait(display:DisplayObject=null, layerId:String=null, addChildren:Boolean=true){
			super(display);
			_layerId = layerId;
			
			this.addChildren = addChildren;
			
			//checkVisibility();
		}
		protected function checkVisibility():void{
			if(_displayObject)_displayObject.visible = _visible;
		}
	}
}