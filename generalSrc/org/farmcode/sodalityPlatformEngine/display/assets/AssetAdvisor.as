package org.farmcode.sodalityPlatformEngine.display.assets
{
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public class AssetAdvisor extends DynamicAdvisor
	{	
		public function get rootDisplay():DisplayObject{
			return _rootDisplay;
		}
		public function set rootDisplay(value:DisplayObject):void{
			if(_rootDisplay != value){
				if(_rootDisplay){
					_rootDisplay.removeEventListener(Event.ADDED, onChildAdded);
					_rootDisplay.removeEventListener(Event.REMOVED, onChildRemoved);
				}
				_rootDisplay = value;
				if(_rootDisplay){
					_rootDisplay.addEventListener(Event.ADDED, onChildAdded);
					_rootDisplay.addEventListener(Event.REMOVED, onChildRemoved);
					DisplayUtils.executeForDescendants(this.rootDisplay,assessChildAdd,Sprite);
				}
			}
		}
		
		public var assetTypes:Array;
		
		private var _rootDisplay:DisplayObject;
		private var _firedAdvice:Dictionary = new Dictionary();
		
		public function AssetAdvisor(){
			super();
		}
		protected function onChildAdded(e:Event):void{
			var added:DisplayObject = (e.target as DisplayObject);
			DisplayUtils.executeForDescendants(added,assessChildAdd,Sprite);
		}
		protected function assessChildAdd(child:Sprite):void{
			var adviceList:Array = [];
			for each(var assetType:AssetType in assetTypes){
				if(child is assetType.assetClass){
					var advice:IAdvice = assetType.advice.cloneAdvice();
					setProperty(advice, assetType.adviceProperty, getProperty(child, assetType.assetProperty));
					dispatchEvent(advice as Event);
					if(advice is IRevertableAdvice){
						adviceList.push(advice);
					}
				}
			}
			if(adviceList.length){
				_firedAdvice[child] = adviceList;
			}
		}
		protected function onChildRemoved(e:Event):void{
			var removed:DisplayObject = (e.target as DisplayObject);
			DisplayUtils.executeForDescendants(removed,assessChildRemoved,Sprite);
		}
		protected function assessChildRemoved(child:Sprite):void{
			var adviceList:Array = _firedAdvice[child];
			if(adviceList){
				for each(var advice:IRevertableAdvice in adviceList){
					if(advice.doRevert){
						var revert:IAdvice = advice.revertAdvice;
						if(revert){
							dispatchEvent(revert as Event);
						}
					}
				}
				delete _firedAdvice[child];
			}
		}
		protected function setProperty(into:Object, prop:String, value:*):void{
			var parts:Array = prop.split(".");
			while(parts.length>1){
				into = into[parts.shift()];
			}
			into[parts[0]] = value;
		}
		protected function getProperty(from:Object, prop:String):*{
			if(prop){
				var parts:Array = prop.split(".");
				while(parts.length){
					from = from[parts.shift()];
				}
			}
			return from;
		}
	}
}