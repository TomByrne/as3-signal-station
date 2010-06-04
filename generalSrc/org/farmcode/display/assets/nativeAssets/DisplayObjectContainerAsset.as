package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.NativeAct;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.states.IStateDef;
	import org.farmcode.display.utils.MovieClipUtils;
	import org.farmcode.hoborg.ObjectPool;
	
	public class DisplayObjectContainerAsset extends InteractiveObjectAsset implements IContainerAsset
	{
		private static var assignments:Dictionary = new Dictionary(true);
		
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				var assArray:Array;
				if(_displayObjectContainer){
					assArray = assignments[_displayObjectContainer];
					var index:int = assArray.indexOf(this);
					assArray.splice(index,1);
					if(!assArray.length){
						delete assignments[_displayObjectContainer];
					}
					_children = new Dictionary();
				}
				super.displayObject = value;
				if(value){
					_displayObjectContainer = value as DisplayObjectContainer;
					assArray = assignments[value];
					if(!assArray){
						assArray = [];
						assignments[value] = assArray;
					}
					assArray.push(this);
				}else{
					_displayObjectContainer = null;
				}
			}
		}
		
		public function get mouseChildren():Boolean{
			return _displayObjectContainer.mouseChildren;
		}
		public function set mouseChildren(value:Boolean):void{
			_displayObjectContainer.mouseChildren = value;
		}
		public function get numChildren():int{
			return _displayObjectContainer.numChildren;
		}
		
		private var _mouseChildren:Boolean;
		private var _displayObjectContainer:DisplayObjectContainer;
		/*
		mapped DisplayObject -> IDisplayAsset
		*/
		private var _children:Dictionary = new Dictionary(true);
		
		public function DisplayObjectContainerAsset(){
		}
		
		public function containsAssetByName(name:String):Boolean{
			if(_displayObjectContainer){
				var displayObject:DisplayObject = _displayObjectContainer.getChildByName(name);
				return (displayObject!=null);
			}else{
				throw new Error("This method cannot be called before a displayObject is set");
			}
		}
		
		public function takeAssetByName(name:String, type:Class, optional:Boolean=false):*{
			if(_displayObjectContainer){
				var displayObject:DisplayObject = _displayObjectContainer.getChildByName(name);
				if(displayObject){
					var ret:DisplayObjectAsset = _children[displayObject];
					if(!ret){
						ret = NativeAssetFactory.getNew(displayObject);
						storeChildAsset(ret,displayObject);
					}
					return ret;
				}else if(!optional){
					throw new Error("Child DisplayObject with name "+name+" was not found");
				}
			}else{
				throw new Error("This method cannot be called before a displayObject is set");
			}
		}
		public function returnAsset(asset:IAsset):void{
			// nothing to do
		}
		public function addAsset(asset:IAsset):void{
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			_displayObjectContainer.addChild(cast.displayObject);
			storeChildAsset(cast,cast.displayObject);
		}
		public function removeAsset(asset:IAsset):void{
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			_displayObjectContainer.removeChild(cast.displayObject);
			removeChildAsset(cast,cast.displayObject);
		}
		public function setAssetIndex(asset:IAsset, index:int):void{
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			_displayObjectContainer.setChildIndex(cast.displayObject,index);
			storeChildAsset(cast,cast.displayObject);
		}
		
		override public function addStateList(stateList:Array):void{
			super.addStateList(stateList);
			for each(var child:IDisplayAsset in _children){
				child.addStateList(stateList);
			}
		}
		override public function removeStateList(stateList:Array):void{
			super.removeStateList(stateList);
			for each(var child:IDisplayAsset in _children){
				child.removeStateList(stateList);
			}
		}
		override public function release():void{
			super.release();
			for each(var child:IDisplayAsset in _children){
				for each(var stateList:Array in _stateLists){
					child.removeStateList(stateList);
				}
				child.release();
			}
			_children = new Dictionary(true);
		}
		
		protected function storeChildAsset(child:IDisplayAsset, displayObject:DisplayObject):void{
			for each(var stateList:Array in _stateLists){
				child.addStateList(stateList);
			}
			_children[displayObject] = child;
		}
		protected function removeChildAsset(child:IDisplayAsset, displayObject:DisplayObject):void{
			for each(var stateList:Array in _stateLists){
				child.removeStateList(stateList);
			}
			delete _children[displayObject];
		}
		protected function findChildByName(name:String):IDisplayAsset{
			for each(var child:IDisplayAsset in _children){
				if(child.name==name){
					return child;
				}
			}
			return null;
		}
	}
}