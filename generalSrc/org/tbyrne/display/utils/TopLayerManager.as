package org.tbyrne.display.utils
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.assetTypes.IStageAsset;
	
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

import org.tbyrne.display.assets.assetTypes.IAsset;
import org.tbyrne.display.assets.assetTypes.IContainerAsset;
import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
import org.tbyrne.display.assets.assetTypes.IStageAsset;

class TopLayerBundle{
	private var stage:IStageAsset;
	private var container:IContainerAsset;
	private var displays:Dictionary = new Dictionary();
	private var addedDisplays:int = 0;
	
	public function TopLayerBundle(stage:IStageAsset){
		this.stage = stage;
		container = stage.factory.createContainer();
		container.mouseEnabled = false;
		stage.addAsset(container);
		stage.added.addHandler(onAdded);
	}
	public function addDisplay(display:IDisplayAsset):void{
		if(!displays[display]){
			++addedDisplays;
			displays[display] = true;
			container.addAsset(display);
		}
	}
	// returns true if it is now empty and should be removed
	public function removeDisplay(display:IDisplayAsset):Boolean{
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
		stage.factory.destroyAsset(container);
		stage = null;
	}
	public function onAdded(e:Event, from:IStageAsset):void{
		var added:DisplayObject = (e.target as DisplayObject);
		if(added.parent==stage){
			stage.setAssetIndex(container,stage.numChildren-1);
		}
	}
}