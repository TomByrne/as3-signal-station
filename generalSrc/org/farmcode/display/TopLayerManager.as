package org.farmcode.display
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.Dictionary;

	public class TopLayerManager
	{
		protected static var containerLookup:Dictionary = new Dictionary();
		
		public static function add(display:DisplayObject, container:DisplayObjectContainer):void{
			if(container){
				var manager:TopLayerManager = containerLookup[container];
				if(!manager){
					containerLookup[container] = manager = new TopLayerManager(container);
				}
				manager.addDisplay(display);
			}else{
				throw new Error("TopLayerManager needs a reference to a DisplayObjectContainer");
			}
		}
		public static function remove(display:DisplayObject):void{
			var container:DisplayObjectContainer = display.parent.parent;
			var manager:TopLayerManager = containerLookup[container];
			if(manager.removeDisplay(display)){
				delete containerLookup[container];
				bundle.dispose();
			}
		}
		public static function sendToFront(display:DisplayObject):void{
			var container:DisplayObjectContainer = display.parent.parent;
			var manager:TopLayerManager = containerLookup[container];
			manager.sendToFront(display);
		}
		public static function sendToBack(display:DisplayObject):void{
			var container:DisplayObjectContainer = display.parent.parent;
			var manager:TopLayerManager = containerLookup[container];
			manager.sendToBack(display);
		}
		
		
		
		
		
		private var container:DisplayObjectContainer;
		private var innerContainer:Sprite;
		private var displays:Dictionary = new Dictionary();
		private var addedDisplays:int = 0;
		
		public function TopLayerManager(container:DisplayObjectContainer){
			this.container = container;
			innerContainer = new Sprite();
			container.addChild(innerContainer);
			container.addEventListener(Event.ADDED, onAdded);
		}
		public function sendToFront(display:DisplayObject):void{
			innerContainer.setChildIndex(display,innerContainer.numChildren-1);
		}
		public function sendToBack(display:DisplayObject):void{
			innerContainer.setChildIndex(display,0);
		}
		public function addDisplay(display:DisplayObject):void{
			if(!displays[display]){
				++addedDisplays;
				displays[display] = true;
				innerContainer.addChild(display);
			}else{
				innerContainer.setChildIndex(display,innerContainer.numChildren-1);
			}
		}
		// returns true if it is now empty and should be removed
		public function removeDisplay(display:DisplayObject):Boolean{
			if(displays[display]){
				delete displays[display];
				--addedDisplays;
				innerContainer.removeChild(display);
				return (addedDisplays==0);
			}else{
				return false;
			}
		}
		internal function dispose():void{
			stage.removeEventListener(Event.ADDED, onAdded);
			stage.removeChild(innerContainer);
			stage = null;
		}
		private function onAdded(e:Event):void{
			var added:DisplayObject = (e.target as DisplayObject);
			if(added.parent==stage){
				stage.setChildIndex(innerContainer,container.numChildren-1);
			}
		}
	}
}