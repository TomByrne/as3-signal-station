package org.tbyrne.display.validation
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public class FrameValidationManager
	{
		{
			frameDispatcher = new Shape();
			_instance = new FrameValidationManager();
		}
		private static var frameDispatcher:Shape;
		private static var _instance:FrameValidationManager;
		public static function get instance():FrameValidationManager{
			return _instance;
		}
		
		
		// mapped flag > true
		private var flags:Dictionary = new Dictionary();
		private var pendingFlags:Array = [];
		private var rootBundles:Array = [];
		// mapped asset > AssetBundle
		protected var bundleMap:Dictionary = new Dictionary();
		// mapped validationFlag > AssetBundle
		protected var flagToBundle:Dictionary = new Dictionary();
		// mapped AssetBundle > DrawRun
		protected var currentRuns:Dictionary = new Dictionary();
		protected var currentRunCount:int = 0;
		
		public function FrameValidationManager(){
			frameDispatcher.addEventListener(Event.ENTER_FRAME, onRender);
		}
		protected function onRender(e:Event):void{
			assessAllFlags();
			startDrawRun(null);
		}
		public function validate(flag:IFrameValidationFlag):void{
			assessAllFlags();
			if(flag.readyForExecution){
				startDrawRun(flag);
			}
		}
		public function addFrameValFlag(flag:IFrameValidationFlag):void{
			CONFIG::debug{
				if(flags[flag]){
					Log.error( "FrameValidationManager.addFrameValFlag: Trying to add flag twice");
				}
			}
			flags[flag] = true;
			if(currentRunCount){
				assessFlag(flag);
			}else{
				pendingFlags.push(flag);
			}
		}
		public function removeFrameValFlag(flag:IFrameValidationFlag):void{
			CONFIG::debug{
				if(!flags[flag]){
					Log.error( "FrameValidationManager.removeFrameValFlag: Trying to remove a non-added flag");
				}
			}
			var index:int = pendingFlags.indexOf(flag);
			if(index==-1){
				var bundle:AssetBundle = flagToBundle[flag];;
				removeFromBundle(flag, bundle);
				removeFromRuns(flag);
				flag.assetChanged.removeHandler(onFlagAssetChanged);
			}else{
				pendingFlags.splice(index);
			}
			delete flags[flag];
		}
		
		protected function assessAllFlags():void{
			for each(var flag:IFrameValidationFlag in pendingFlags){
				assessFlag(flag);
			}
			pendingFlags = [];
		}
		/**
		 * Adds this IFrameValidationFlag object into the asset heirarchy.
		 */
		protected function assessFlag(flag:IFrameValidationFlag):void{
			flag.assetChanged.addHandler(onFlagAssetChanged);
			addToBundle(flag);
			addToRuns(flag);
		}
		protected function onFlagAssetChanged(from:IFrameValidationFlag, oldAsset:IDisplayObject):void{
			var oldBundle:AssetBundle = flagToBundle[from];
			var oldRun:DrawRun;
			
			oldRun = findRunForBundle(oldBundle);
			removeFromBundle(from, oldBundle);
			
			var newBundle:AssetBundle = addToBundle(from);
			checkIfRunChange(from, newBundle, oldRun);
		}
		protected function addToBundle(flag:IFrameValidationFlag):AssetBundle{
			var bundle:AssetBundle = bundleMap[flag.asset];
			if(!bundle){
				bundle = AssetBundle.getNew(flag.asset);
				bundleMap[flag.asset] = bundle;
				bundle.assetPosChanged.addHandler(onAssetPosChanged);
				if(bundle.readyForExecution)addToHeirarchy(bundle);
			}
			flagToBundle[flag] = bundle;
			bundle.addValidationFlag(flag);
			return bundle;
		}
		protected function removeFromBundle(flag:IFrameValidationFlag, bundle:AssetBundle):void{
			bundle.removeValidationFlag(flag);
			if(!bundle.validationFlagCount){
				removeFromHeirarchy(bundle);
				delete bundleMap[bundle.asset];
				bundle.assetPosChanged.removeHandler(onAssetPosChanged);
				bundle.release();
			}
			delete flagToBundle[flag];
		}
		protected function onAssetPosChanged(bundle:AssetBundle):void{
			var oldRun:DrawRun = findRunForBundle(bundle);
			removeFromHeirarchy(bundle);
			if(bundle.readyForExecution)addToHeirarchy(bundle);
			checkIfRunChange(null, bundle, oldRun);
		}
		protected function checkIfRunChange(flag:IFrameValidationFlag, bundle:AssetBundle, oldRun:DrawRun):void{
			var newRun:DrawRun;
			if(bundle)newRun = findRunForBundle(bundle);
			if(newRun!=oldRun){
				if(flag){
					if(oldRun)oldRun.removePending(flag);
					if(newRun)newRun.addPending(flag);
				}else{
					for each(flag in bundle.validationFlags){
						if(oldRun)oldRun.removePending(flag);
						if(newRun)newRun.addPending(flag);
					}
				}
			}
		}
		protected function addToHeirarchy(bundle:AssetBundle):void{
			var subject:IDisplayObject = bundle.asset;
			var parentBundle:AssetBundle;
			while(subject && !(parentBundle = bundleMap[subject.parent])){
				subject = subject.parent;
			}
			if(parentBundle){
				stealChildren(bundle, parentBundle.children);
				parentBundle.addChild(bundle);
			}else{
				stealChildren(bundle, rootBundles);
				rootBundles.push(bundle);
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
				var index:int = rootBundles.indexOf(bundle);
				if(index!=-1){
					rootBundles.splice(index,1);
					while(bundle.children.length){
						child = bundle.children[0];
						bundle.removeChild(child);
						rootBundles.push(child);
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
		protected function isDescendant(parent:IDisplayObject, child:IDisplayObject):Boolean{
			var subject:IDisplayObject = child.parent;
			while(subject && subject!=parent){
				subject = subject.parent;
			}
			return (subject!=null);
		}
		protected function startDrawRun(flag:IFrameValidationFlag):void{
			var childRuns:Array;
			var drawRun:DrawRun;
			if(flag){
				var asset:IDisplayObject = flag.asset;
				var existingRun:DrawRun;
				childRuns = [];
				if(currentRunCount){
					for each(drawRun in currentRuns){
						var otherAsset:IDisplayObject = drawRun.root.asset;
						if(otherAsset){
							if(otherAsset==asset || isDescendant(otherAsset,asset)){
								existingRun = drawRun;
								break;
							}else if(isDescendant(asset,otherAsset)){
								childRuns.push(drawRun);
							}
						}
					}
				}
				if(existingRun){
					existingRun.forceExecute(flag);
				}else{
					createNewRun(flagToBundle[flag], childRuns);
				}
			}else{
				for each(var bundle:AssetBundle in rootBundles){
					childRuns = [];
					for each(drawRun in currentRuns){
						if(!drawRun.root.asset || isDescendant(bundle.asset,drawRun.root.asset)){
							childRuns.push(drawRun);
						}
					}
					createNewRun(bundle, childRuns);
				}
			}
		}
		protected function createNewRun(bundle:AssetBundle, childRuns:Array):void{
			var run:DrawRun = DrawRun.getNew(bundle);
			currentRuns[bundle] = run;
			++currentRunCount;
			run.execute(childRuns);
			// If we were to make this asynchronous, we'd do it right here
			--currentRunCount;
			delete currentRuns[bundle];
			run.release();
		}
		/**
		 * Adds this flag to the applicable running DrawRun
		 */
		protected function addToRuns(flag:IFrameValidationFlag):void{
			var run:DrawRun = findRunForAsset(flag.asset);
			if(run){
				run.addPending(flag);
			}
		}
		/**
		 * Removed this flag from the applicable running DrawRun
		 */
		protected function removeFromRuns(flag:IFrameValidationFlag):void{
			var run:DrawRun = findRunForAsset(flag.asset);
			if(run){
				run.removePending(flag);
			}
		}
		protected function findRunForAsset(asset:IDisplayObject):DrawRun{
			if(currentRunCount && asset){
				for each(var drawRun:DrawRun in currentRuns){
					if(isDescendant(drawRun.root.asset,asset)){
						return drawRun;
					}
				}
			}
			return null;
		}
		protected function findRunForBundle(bundle:AssetBundle):DrawRun{
			if(currentRunCount){
				for each(var drawRun:DrawRun in currentRuns){
					var subject:AssetBundle = bundle;
					while(subject){
						if(drawRun.root==subject){
							return drawRun;
						}
						subject = subject.parent;
					}
				}
			}
			return null;
		}
	}
}
import flash.events.Event;
import flash.utils.Dictionary;

import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import Log;
import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
import org.tbyrne.display.validation.IFrameValidationFlag;
import org.tbyrne.hoborg.IPoolable;
import org.tbyrne.hoborg.ObjectPool;

class AssetBundle implements IPoolable{
	private static const pool:ObjectPool = new ObjectPool(AssetBundle);
	public static function getNew(asset:IDisplayObject):AssetBundle{
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
	
	public function get asset():IDisplayObject{
		return _asset;
	}
	public function set asset(value:IDisplayObject):void{
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
	protected var _asset:IDisplayObject;
	protected var _assetPosChanged:Act = new Act();
	
	
	protected function onAdded(from:IDisplayObject):void{
		if(!_addedToStage){
			_addedToStage = true;
			_assetPosChanged.perform(this);
		}
	}
	protected function onRemoved(from:IDisplayObject):void{
		if(_addedToStage){
			_addedToStage = false;
			_assetPosChanged.perform(this);
		}
	}
	public function addChild(bundle:AssetBundle):void{
		CONFIG::debug{
			if(children.indexOf(bundle)!=-1){
				Log.error( "AssetBundle.addChild: child already added");
			}
		}
		bundle.parent = this;
		children.push(bundle);
	}
	public function removeChild(bundle:AssetBundle):void{
		var index:int = children.indexOf(bundle);
		CONFIG::debug{
			if(index==-1){
				Log.error( "AssetBundle.removeChild: child not added");
			}
		}
		bundle.parent = null;
		children.splice(index,1);
	}
	
	public function addValidationFlag(validationFlag:IFrameValidationFlag):void{
		CONFIG::debug{
			if(validationFlags.indexOf(validationFlag)!=-1){
				Log.error( "AssetBundle.addValidationFlag: flag already added");
			}
		}
		validationFlags.push(validationFlag);
	}
	public function removeValidationFlag(validationFlag:IFrameValidationFlag):void{
		var index:int = validationFlags.indexOf(validationFlag);
		CONFIG::debug{
			if(index==-1){
				Log.error( "AssetBundle.removeValidationFlag: flag not added");
			}
		}
		validationFlags.splice(index,1);
	}
	public function execute():void{
		for each(var flag:IFrameValidationFlag in validationFlags){
			flag.execute();
		}
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
class DrawRun implements IPoolable{
	private static const pool:ObjectPool = new ObjectPool(DrawRun);
	public static function getNew(root:AssetBundle):DrawRun{
		var ret:DrawRun = pool.takeObject();
		ret.root = root;
		return ret;
	}
	
	public var root:AssetBundle;
	private var pendingDraws:Array = [];
	public var currentIndex:int = 0;
	public var hasDrawnThisRun:Boolean;
	
	// THIS NEEDS TO ADD TO THE CORRECT POSITION.
	// after currentIndex but before any descendents
	public function addPending(flag:IFrameValidationFlag):void{
		CONFIG::debug{
			if(pendingDraws.indexOf(flag)!=-1){
				Log.error( "DrawRun.addPending: Trying to add already added flag");
			}
		}
		pendingDraws.push(flag);
	}
	public function removePending(flag:IFrameValidationFlag):void{
		var index:int = pendingDraws.indexOf(flag);
		if(index!=-1){
			pendingDraws.splice(index,1);
		}
	}
	public function execute(childRuns:Array):void{
		var childBundles:Dictionary = new Dictionary();
		for each(var childRun:DrawRun in childRuns){
			pendingDraws = pendingDraws.concat(childRun.pendingDraws);
			childBundles[childRun.root] = true;
		}
		addFlagsExcept(root,childBundles);
		while(true){
			hasDrawnThisRun = false;
			currentIndex = 0;
			while(currentIndex<pendingDraws.length && currentIndex>=0){
				var flag:IFrameValidationFlag = pendingDraws[currentIndex];
				if(!flag.valid && flag.readyForExecution){
					executeFlag(flag, currentIndex);
				}else{
					currentIndex++;
				}
			}
			if(!hasDrawnThisRun){
				break;
			}
			// should it be resorted here (if flags have ben added/removed)?
		}
	}
	protected function addFlagsExcept(asset:AssetBundle, except:Dictionary):void{
		if(!except[asset]){
			for each(var flag:IFrameValidationFlag in asset.validationFlags){
				pendingDraws.push(flag);
			}
			for each(var child:AssetBundle in asset.children){
				addFlagsExcept(child,except);
			}
		}
	}
	public function forceExecute(flag:IFrameValidationFlag):void{
		if(flag.readyForExecution && !flag.valid){
			var index:int = pendingDraws.indexOf(flag);
			if(index!=-1 && currentIndex>index){
				--currentIndex;
			}
			executeFlag(flag, index);
		}
	}
	protected function executeFlag(flag:IFrameValidationFlag, index:int):void{
		pendingDraws.splice(index,1); //TODO: optimise all this splicing out
		hasDrawnThisRun = true;
		flag.execute();
	}
	public function reset():void{
		root = null;
		pendingDraws = [];
		currentIndex = 0;
		hasDrawnThisRun = false;
	}
	public function release():void{
		pool.releaseObject(this);
	}
}