package org.tbyrne.display.validation
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.IScopedObject;
	
	public class ScopedObjectTree
	{
		public var assessImmediately:Boolean = false;
		
		// mapped IScopedObject > true
		protected var _scopedObjects:Dictionary = new Dictionary();
		// these are scoped objects whose scope haven't yet been checked
		protected var _pendingScopedObjects:Vector.<AssetBundle> = new Vector.<AssetBundle>();
		protected var _rootBundles:Vector.<AssetBundle> = new Vector.<AssetBundle>();
		// mapped asset > AssetBundle
		protected var _assetToBundleMap:Dictionary = new Dictionary();
		
		public function ScopedObjectTree(){
		}
		public function addScopedObject(scopedObject:IScopedObject):void{
			CONFIG::debug{
				if(_scopedObjects[scopedObject]){
					throw new Error("Trying to add IScopedObject twice");
				}
			}
			_scopedObjects[scopedObject] = true;
			if(assessImmediately){
				assessScopedObject(scopedObject);
			}else{
				_pendingScopedObjects.push(scopedObject);
			}
		}
		public function removeScopedObject(scopedObject:IScopedObject):void{
			CONFIG::debug{
				if(!_scopedObjects[scopedObject]){
					throw new Error("Trying to remove a non-added IScopedObject");
				}
			}
			var index:int = _pendingScopedObjects.indexOf(scopedObject);
			if(index==-1){
				var bundle:AssetBundle = _assetToBundleMap[scopedObject.asset];
				removeFromBundle(scopedObject, bundle);
				scopedObject.assetChanged.removeHandler(onAssetChanged);
			}else{
				_pendingScopedObjects.splice(index);
			}
			delete _scopedObjects[scopedObject];
		}
		
		protected function assessAllScopedObject():void{
			for each(var scopedObject:IScopedObject in _pendingScopedObjects){
				assessScopedObject(scopedObject);
			}
			_pendingScopedObjects = [];
		}
		/**
		 * Adds this IScopedObject object into the asset heirarchy.
		 */
		protected function assessScopedObject(scopedObject:IScopedObject):void{
			flag.assetChanged.addHandler(onAssetChanged);
			addToBundle(flag);
		}
		protected function onAssetChanged(from:IScopedObject, oldAsset:IDisplayAsset):void{
			var oldBundle:AssetBundle = _assetToBundleMap[oldAsset];
			removeFromBundle(from, oldBundle);
			
			var newBundle:AssetBundle = addToBundle(from);
		}
		protected function addToBundle(scopedObject:IScopedObject):AssetBundle{
			var bundle:AssetBundle = _assetToBundleMap[flag.asset];
			if(!bundle){
				bundle = AssetBundle.getNew(flag.asset);
				_assetToBundleMap[flag.asset] = bundle;
				bundle.assetPosChanged.addHandler(onAssetPosChanged);
				if(bundle.readyForExecution)addToHeirarchy(bundle);
			}
			bundle.addValidationFlag(flag);
			return bundle;
		}
		protected function removeFromBundle(scopedObject:IScopedObject, bundle:AssetBundle):void{
			bundle.removeValidationFlag(flag);
			if(!bundle.validationFlagCount){
				removeFromHeirarchy(bundle);
				delete _assetToBundleMap[bundle.asset];
				bundle.assetPosChanged.removeHandler(onAssetPosChanged);
				bundle.release();
			}
		}
		protected function onAssetPosChanged(bundle:AssetBundle):void{
			removeFromHeirarchy(bundle);
			if(bundle.readyForExecution)addToHeirarchy(bundle);
		}
		protected function addToHeirarchy(bundle:AssetBundle):void{
			var subject:IDisplayAsset = bundle.asset;
			var parentBundle:AssetBundle;
			while(subject && !(parentBundle = _assetToBundleMap[subject.parent])){
				subject = subject.parent;
			}
			if(parentBundle){
				stealChildren(bundle, parentBundle.children);
				parentBundle.addChild(bundle);
			}else{
				stealChildren(bundle, _rootBundles);
				_rootBundles.push(bundle);
			}
		}
		protected function removeFromHeirarchy(bundle:AssetBundle):void{
			var child:AssetBundle;
			if(bundle.parent){
				while(bundle.children.length){
					child = bundle.children[0];
					bundle.removeChild(child);
					bundle.parent.addChild(child);
				}
				bundle.parent.removeChild(bundle);
			}else{
				var index:int = _rootBundles.indexOf(bundle);
				if(index!=-1){
					_rootBundles.splice(index,1);
					while(bundle.children.length){
						child = bundle.children[0];
						bundle.removeChild(child);
						_rootBundles.push(child);
					}
				}
			}
		}
		/**
		 * Analyses a list of children and transfers them to the bundle when they fall underneath
		 * the bundles asset.
		 */
		protected function stealChildren(bundle:AssetBundle, children:Array):void{
			for(var i:int=0; i<children.length; i++){
				var child:AssetBundle = children[i];
				if(isDescendant(bundle.asset, child.asset)){
					bundle.addChild(child);
					children.splice(i,1);
				}
			}
		}
		protected function isDescendant(parent:IDisplayAsset, child:IDisplayAsset):Boolean{
			var subject:IDisplayAsset = child.parent;
			while(subject && subject!=parent){
				subject = subject.parent;
			}
			return (subject!=null);
		}
	}
}
import flash.utils.Dictionary;

import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
import org.tbyrne.display.core.IScopedObject;
import org.tbyrne.hoborg.IPoolable;
import org.tbyrne.hoborg.ObjectPool;

class AssetBundle implements IPoolable{
	private static const pool:ObjectPool = new ObjectPool(AssetBundle);
	public static function getNew(asset:IDisplayAsset):AssetBundle{
		var ret:AssetBundle = pool.takeObject();
		ret.asset = asset;
		return ret;
	}
	
	
	/**
	 * handler(from:AssetBundle)
	 */
	public function get assetPosChanged():IAct{
		return _assetPosChanged;
	}
	
	public function get validationFlagCount():int{
		return validationFlags.length;
	}
	
	public function get asset():IDisplayAsset{
		return _asset;
	}
	public function set asset(value:IDisplayAsset):void{
		if(_asset!=value){
			if(_asset){
				_asset.addedToStage.removeHandler(onAdded);
				_asset.removedFromStage.removeHandler(onRemoved);
			}
			_asset = value;
			if(_asset){
				_asset.addedToStage.addHandler(onAdded);
				_asset.removedFromStage.addHandler(onRemoved);
				_addedToStage = (_asset.stage!=null);
			}else{
				_addedToStage = false;
			}
		}
	}
	public function get readyForExecution():Boolean{
		return !_asset || _addedToStage;
	}
	
	public var parent:AssetBundle;
	public var children:Array = [];
	public var validationFlags:Array = [];
	
	protected var _addedToStage:Boolean;
	protected var _asset:IDisplayAsset;
	protected var _assetPosChanged:Act = new Act();
	
	
	protected function onAdded(from:IDisplayAsset):void{
		_addedToStage = true;
		_assetPosChanged.perform(this);
	}
	protected function onRemoved(from:IDisplayAsset):void{
		_addedToStage = false;
		_assetPosChanged.perform(this);
	}
	public function addChild(bundle:AssetBundle):void{
		CONFIG::debug{
			if(children.indexOf(bundle)!=-1){
				throw new Error("child already added");
			}
		}
		bundle.parent = this;
		children.push(bundle);
	}
	public function removeChild(bundle:AssetBundle):void{
		var index:int = children.indexOf(bundle);
		CONFIG::debug{
			if(index==-1){
				throw new Error("child not added");
			}
		}
		bundle.parent = null;
		children.splice(index,1);
	}
	
	public function addValidationFlag(validationscopedObject:IScopedObject):void{
		CONFIG::debug{
			if(validationFlags.indexOf(validationFlag)!=-1){
				throw new Error("flag already added");
			}
		}
		validationFlags.push(validationFlag);
	}
	public function removeValidationFlag(validationscopedObject:IScopedObject):void{
		var index:int = validationFlags.indexOf(validationFlag);
		CONFIG::debug{
			if(index==-1){
				throw new Error("flag not added");
			}
		}
		validationFlags.splice(index,1);
	}
	
	public function reset():void{
		asset = null
		validationFlags = [];
		parent = null;
		children = [];
	}
	public function release():void{
		pool.releaseObject(this);
	}
}
