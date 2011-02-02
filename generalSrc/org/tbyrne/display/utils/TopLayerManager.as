package org.tbyrne.display.utils
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	
	public class TopLayerManager
	{
		protected static var parentLookup:Dictionary = new Dictionary();
		
		public static function add(display:IDisplayObject, container:IDisplayObjectContainer):void{
			if(!container)container = display.stage;
			if(container){
				var bundle:TopLayerBundle = parentLookup[container];
				if(!bundle){
					parentLookup[container] = bundle = new TopLayerBundle(container);
				}
				bundle.addDisplay(display);
			}else{
				throw new Error("TopLayerManager needs a reference to the container");
			}
		}
		public static function remove(display:IDisplayObject):void{
			var container:IDisplayObjectContainer = display.parent.parent;
			var bundle:TopLayerBundle = parentLookup[container];
			if(bundle.removeDisplay(display)){
				delete parentLookup[container];
				bundle.dispose();
			}
		}
	}
}
import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;

import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;

class TopLayerBundle{
	private var outerContainer:IDisplayObjectContainer;
	private var innerContainer:IDisplayObjectContainer;
	private var displays:Dictionary = new Dictionary();
	private var addedDisplays:int = 0;
	
	public function TopLayerBundle(container:IDisplayObjectContainer){
		this.outerContainer = container;
		innerContainer = container.factory.createContainer();
		innerContainer.mouseEnabled = false;
		container.addAsset(innerContainer);
		container.added.addHandler(onAdded);
	}
	public function addDisplay(display:IDisplayObject):void{
		if(!displays[display]){
			++addedDisplays;
			displays[display] = true;
			innerContainer.addAsset(display);
		}
	}
	// returns true if it is now empty and should be removed
	public function removeDisplay(display:IDisplayObject):Boolean{
		if(displays[display]){
			delete displays[display];
			--addedDisplays;
			innerContainer.removeAsset(display);
			return (addedDisplays==0);
		}else{
			return false;
		}
	}
	public function dispose():void{
		outerContainer.added.removeHandler(onAdded);
		outerContainer.removeAsset(innerContainer);
		outerContainer.factory.destroyAsset(innerContainer);
		outerContainer = null;
	}
	public function onAdded(e:Event, from:IDisplayObjectContainer):void{
		var added:DisplayObject = (e.target as DisplayObject);
		if(added.parent==outerContainer){
			outerContainer.setAssetIndex(innerContainer,outerContainer.numChildren-1);
		}
	}
}