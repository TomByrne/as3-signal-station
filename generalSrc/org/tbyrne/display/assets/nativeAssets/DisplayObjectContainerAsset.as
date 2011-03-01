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
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.states.IStateDef;
	import org.tbyrne.display.assets.utils.isDescendant;
	import org.tbyrne.display.utils.MovieClipUtils;
	import org.tbyrne.hoborg.ObjectPool;
	
	public class DisplayObjectContainerAsset extends InteractiveObjectAsset implements IDisplayObjectContainer
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
					for each(var child:IDisplayObject in _children){
						for each(var stateList:Array in _stateLists){
							child.removeStateList(stateList);
						}
						child.parent = null;
						_nativeFactory.destroyAsset(child);
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
		mapped DisplayObject -> IDisplayObject
		*/
		private var _children:Dictionary = new Dictionary(true);
		
		public function DisplayObjectContainerAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
		
		public function getAssetIndex(asset:IDisplayObject):int{
			if(_displayObjectContainer){
				var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
				return _displayObjectContainer.getChildIndex(cast.displayObject);
			}else{
				Log.error( "DisplayObjectContainerAsset.getAssetIndex: This method cannot be called before a displayObject is set");
				return -1;
			}
		}
		public function containsAssetByName(name:String):Boolean{
			if(_displayObjectContainer){
				var displayObject:DisplayObject = _displayObjectContainer.getChildByName(name);
				return (displayObject!=null);
			}else{
				Log.error( "DisplayObjectContainerAsset.containsAssetByName: This method cannot be called before a displayObject is set");
				return false;
			}
		}
		public function contains(child:IDisplayObject):Boolean{
			if(_displayObjectContainer){
				var nativeAsset:INativeAsset = (child as INativeAsset);
				if(child==this || (nativeAsset && _children[nativeAsset.displayObject])){
					return true;
				}else if(_displayObjectContainer){
					var cast:INativeAsset = (child as INativeAsset);
					if(cast){
						return _displayObjectContainer.contains(cast.displayObject);
					}
				}
				return isDescendant(this,child);
			}else{
				Log.error( "DisplayObjectContainerAsset.contains: This method cannot be called before a displayObject is set");
				return false;
			}
		}
		
		public function takeAssetByName(name:String, optional:Boolean=false):*{
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
					Log.error( "DisplayObjectContainerAsset.takeAssetByName: Child DisplayObject with name "+name+" was not found");
				}
			}else{
				Log.error( "DisplayObjectContainerAsset.takeAssetByName: This method cannot be called before a displayObject is set");
			}
		}
		public function returnAsset(asset:IDisplayObject):void{
			// nothing to do
		}
		public function addAsset(asset:IDisplayObject):void{
			var nativeAsset:INativeAsset = (asset as INativeAsset);
			
			/*
			we must store the asset before adding it to heirarchy so that when it binds (as a result of addedToStage)
			it has a reference to the parent asset (and therefore the stage).
			*/
			storeChildAsset(asset,nativeAsset.displayObject);
			
			_displayObjectContainer.addChild(nativeAsset.displayObject);
		}
		public function removeAsset(asset:IDisplayObject):void{
			var nativeAsset:INativeAsset = (asset as INativeAsset);
			_displayObjectContainer.removeChild(nativeAsset.displayObject);
			removeChildAsset(asset,nativeAsset.displayObject);
		}
		public function addAssetAt(asset:IDisplayObject, index:int):IDisplayObject{
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			storeChildAsset(cast,cast.displayObject); //  this must happen before actual adding so that parent ref. exists for event handlers
			_displayObjectContainer.addChildAt(cast.displayObject,index);
			return asset;
		}
		public function getAssetAt(index:int):IDisplayObject{
			if(_displayObjectContainer){
				var displayObject:DisplayObject = _displayObjectContainer.getChildAt(index);
				var ret:DisplayObjectAsset = _children[displayObject];
				if(!ret){
					ret = _nativeFactory.getNew(displayObject);
					storeChildAsset(ret,displayObject);
				}
				return ret;
			}else{
				Log.error( "DisplayObjectContainerAsset.getAssetAt: This method cannot be called before a displayObject is set");
				return null;
			}
		}
		public function setAssetIndex(asset:IDisplayObject, index:int):void{
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			_displayObjectContainer.setChildIndex(cast.displayObject,index);
			storeChildAsset(cast,cast.displayObject);
		}
		
		override protected function _addStateList(stateList:Array):void{
			super._addStateList(stateList);
			for each(var child:IDisplayObject in _children){
				child.addStateList(stateList,true);
			}
		}
		override protected function _removeStateList(stateList:Array):void{
			super._removeStateList(stateList);
			for each(var child:IDisplayObject in _children){
				child.removeStateList(stateList);
			}
		}
		override public function reset():void{
			super.reset();
			for each(var child:IDisplayObject in _children){
				for each(var stateList:Array in _stateLists){
					child.removeStateList(stateList);
				}
				child.parent = null;
				_nativeFactory.destroyAsset(child);
			}
			_children = new Dictionary(true);
		}
		
		protected function storeChildAsset(child:IDisplayObject, displayObject:DisplayObject):void{
			if(!_children[displayObject]){
				child.parent = this;
				for each(var stateList:Array in _stateLists){
					child.addStateList(stateList,true);
				}
				_children[displayObject] = child;
			}
		}
		protected function removeChildAsset(child:IDisplayObject, displayObject:DisplayObject):void{
			if(_children[displayObject]){
				child.parent = null;
				for each(var stateList:Array in _stateLists){
					child.removeStateList(stateList);
				}
				delete _children[displayObject];
			}
		}
		protected function findChildByName(name:String):IDisplayObject{
			for each(var child:IDisplayObject in _children){
				if(child.name==name){
					return child;
				}
			}
			return null;
		}
	}
}