package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.NativeAct;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.assetTypes.IContainerAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.states.IStateDef;
	import org.tbyrne.display.utils.MovieClipUtils;
	import org.tbyrne.hoborg.ObjectPool;
	
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
		
		public function DisplayObjectContainerAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
		
		public function getAssetIndex(asset:IDisplayAsset):int{
			if(_displayObjectContainer){
				var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
				return _displayObjectContainer.getChildIndex(cast.displayObject);
			}else{
				throw new Error("This method cannot be called before a displayObject is set");
			}
		}
		public function containsAssetByName(name:String):Boolean{
			if(_displayObjectContainer){
				var displayObject:DisplayObject = _displayObjectContainer.getChildByName(name);
				return (displayObject!=null);
			}else{
				throw new Error("This method cannot be called before a displayObject is set");
			}
		}
		public function contains(child:IDisplayAsset):Boolean{
			if(_displayObjectContainer){
				var cast:DisplayObjectAsset = (child as DisplayObjectAsset);
				return _displayObjectContainer.contains(cast.displayObject);
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
						ret = _nativeFactory.getNew(displayObject);
						ret.parent = this;
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
		public function returnAsset(asset:IDisplayAsset):void{
			// nothing to do
		}
		public function addAsset(asset:IDisplayAsset):void{
			storeChildAsset(asset,asset.displayObject);
			_displayObjectContainer.addChild(asset.displayObject);
		}
		public function removeAsset(asset:IDisplayAsset):void{
			_displayObjectContainer.removeChild(asset.displayObject);
			removeChildAsset(asset,asset.displayObject);
		}
		public function addAssetAt(asset:IDisplayAsset, index:int):IDisplayAsset{
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			storeChildAsset(cast,cast.displayObject); //  this must happen before actual adding so that parent ref. exists for event handlers
			_displayObjectContainer.addChildAt(cast.displayObject,index);
			return asset;
		}
		public function getAssetAt(index:int):IDisplayAsset{
			if(_displayObjectContainer){
				var displayObject:DisplayObject = _displayObjectContainer.getChildByName(name);
				var ret:DisplayObjectAsset = _children[displayObject];
				if(!ret){
					ret = _nativeFactory.getNew(displayObject);
					storeChildAsset(ret,displayObject);
				}
				return ret;
			}else{
				throw new Error("This method cannot be called before a displayObject is set");
			}
		}
		public function setAssetIndex(asset:IDisplayAsset, index:int):void{
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			_displayObjectContainer.setChildIndex(cast.displayObject,index);
			storeChildAsset(cast,cast.displayObject);
		}
		
		override protected function _addStateList(stateList:Array):void{
			super._addStateList(stateList);
			for each(var child:IDisplayAsset in _children){
				child.addStateList(stateList,true);
			}
		}
		override protected function _removeStateList(stateList:Array):void{
			super._removeStateList(stateList);
			for each(var child:IDisplayAsset in _children){
				child.removeStateList(stateList);
			}
		}
		override public function reset():void{
			super.reset();
			for each(var child:IDisplayAsset in _children){
				for each(var stateList:Array in _stateLists){
					child.removeStateList(stateList);
				}
				_nativeFactory.destroyAsset(child);
			}
			_children = new Dictionary(true);
		}
		
		protected function storeChildAsset(child:IDisplayAsset, displayObject:DisplayObject):void{
			if(!_children[displayObject]){
				child.parent = this;
				for each(var stateList:Array in _stateLists){
					child.addStateList(stateList,true);
				}
				_children[displayObject] = child;
			}
		}
		protected function removeChildAsset(child:IDisplayAsset, displayObject:DisplayObject):void{
			if(_children[displayObject]){
				child.parent = null;
				for each(var stateList:Array in _stateLists){
					child.removeStateList(stateList);
				}
				delete _children[displayObject];
			}
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