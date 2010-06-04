package org.farmcode.display.utils
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IStageAsset;

	public class TopLayerManager
	{
		protected static var stageLookup:Dictionary = new Dictionary();
		
		public static function add(display:IDisplayAsset, stage:IStageAsset):void{
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
		public static function remove(display:IDisplayAsset):void{
			var stage:IStageAsset = display.stage;
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

import org.farmcode.display.assets.IAsset;
import org.farmcode.display.assets.IContainerAsset;
import org.farmcode.display.assets.IStageAsset;

class TopLayerBundle{
	private var stage:IStageAsset;
	private var container:IContainerAsset;
	private var displays:Dictionary = new Dictionary();
	private var addedDisplays:int = 0;
	
	public function TopLayerBundle(stage:IStageAsset){
		this.stage = stage;
		container = stage.createAsset("topLayer",IContainerAsset);
		container.mouseEnabled = false;
		stage.addAsset(container);
		stage.added.addHandler(onAdded);
	}
	public function addDisplay(display:IAsset):void{
		if(!displays[display]){
			++addedDisplays;
			displays[display] = true;
			container.addAsset(display);
		}
	}
	// returns true if it is now empty and should be removed
	public function removeDisplay(display:IAsset):Boolean{
		if(displays[display]){
			delete displays[display];
			--addedDisplays;
			container.removeAsset(display);
			return (addedDisplays==0);
		}else{
			return false;
		}
	}
	public function dispose():void{
		stage.added.removeHandler(onAdded);
		stage.removeAsset(container);
		stage.destroyAsset(container);
		stage = null;
	}
	public function onAdded(e:Event, from:IStageAsset):void{
		var added:DisplayObject = (e.target as DisplayObject);
		if(added.parent==stage){
			stage.setAssetIndex(container,stage.numChildren-1);
		}
	}
}