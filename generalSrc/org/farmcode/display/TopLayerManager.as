package org.farmcode.display
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.utils.Dictionary;

	public class TopLayerManager
	{
		protected static var stageLookup:Dictionary = new Dictionary();
		
		public static function add(display:DisplayObject, stage:Stage):void{
			if(!stage)stage = display.stage;
			if(stage){
				var bundle:TopLayerBundle = stageLookup[stage];
				if(!bundle){
					stageLookup[stage] = bundle = new TopLayerBundle(stage);
				}
				bundle.addDisplay(display);
			}else{
				throw new Error("TopLayerManager needs a reference to the stage");
			}
		}
		public static function remove(display:DisplayObject):void{
			var stage:Stage = display.stage;
			var bundle:TopLayerBundle = stageLookup[stage];
			if(bundle.removeDisplay(display)){
				delete stageLookup[stage];
				bundle.dispose();
			}
		}
	}
}
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.utils.Dictionary;

class TopLayerBundle{
	private var stage:Stage;
	private var container:Sprite;
	private var displays:Dictionary = new Dictionary();
	private var addedDisplays:int = 0;
	
	public function TopLayerBundle(stage:Stage){
		this.stage = stage;
		container = new Sprite();
		stage.addChild(container);
		stage.addEventListener(Event.ADDED, onAdded);
	}
	public function addDisplay(display:DisplayObject):void{
		if(!displays[display]){
			++addedDisplays;
			displays[display] = true;
			container.addChild(display);
		}
	}
	// returns true if it is now empty and should be removed
	public function removeDisplay(display:DisplayObject):Boolean{
		if(displays[display]){
			delete displays[display];
			--addedDisplays;
			container.removeChild(display);
			return (addedDisplays==0);
		}else{
			return false;
		}
	}
	public function dispose():void{
		stage.removeEventListener(Event.ADDED, onAdded);
		stage.removeChild(container);
		stage = null;
	}
	public function onAdded(e:Event):void{
		var added:DisplayObject = (e.target as DisplayObject);
		if(added.parent==stage){
			stage.setChildIndex(container,stage.numChildren-1);
		}
	}
}