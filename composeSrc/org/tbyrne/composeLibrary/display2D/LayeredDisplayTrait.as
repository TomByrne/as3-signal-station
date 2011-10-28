package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.types.display2D.ILayeredDisplayTrait;
	
	public class LayeredDisplayTrait extends DisplayObjectContainerTrait implements ILayeredDisplayTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get moveUp():IAct{
			return (_moveUp || (_moveUp = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveDown():IAct{
			return (_moveDown || (_moveDown = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveToTop():IAct{
			return (_moveToTop || (_moveToTop = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveToBottom():IAct{
			return (_moveToBottom || (_moveToBottom = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveAbove():IAct{
			return (_moveAbove || (_moveAbove = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveBelow():IAct{
			return (_moveBelow || (_moveBelow = new Act()));
		}
		
		/**
		 * handler(from:LayeredDisplayTrait)
		 */
		public function get visibleChanged():IAct{
			return (_visibleChanged || (_visibleChanged = new Act()));
		}
		
		protected var _visibleChanged:Act;
		protected var _moveBelow:Act;
		protected var _moveAbove:Act;
		protected var _moveToBottom:Act;
		protected var _moveToTop:Act;
		protected var _moveDown:Act;
		protected var _moveUp:Act;
		
		
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
		
		protected var _visible:Boolean = true;
		protected var _layerId:String;
		
		
		public function LayeredDisplayTrait(display:DisplayObjectContainer=null, layerId:String=null){
			super(display);
			_layerId = layerId;
			
			checkVisibility();
		}
		protected function checkVisibility():void{
			_container.visible = _visible;
		}
	}
}