package org.tbyrne.display.validation
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;

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
		private var flags:Dictionary;
		private var pendingFlags:Array;
		private var rootBundles:Array;
		// mapped asset > AssetBundle
		protected var bundleMap:Dictionary;
		// mapped validationFlag > AssetBundle
		protected var flagToBundle:Dictionary;
		// mapped AssetBundle > DrawRun
		protected var currentRuns:Dictionary;
		protected var currentRunCount:int = 0;
		protected var _inited:Boolean;
		
		public function FrameValidationManager(){
		}
		public function init():void{
			frameDispatcher.addEventListener(Event.ENTER_FRAME, onRender);
			pendingFlags = new Array();
			rootBundles = new Array();
			currentRuns = new Dictionary();
			flagToBundle = new Dictionary();
			bundleMap = new Dictionary();
			flags = new Dictionary();
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
			if(!_inited){
				_inited = true;
				init();
			}
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
				var bundle:FlagBundle = flagToBundle[flag];;
				removeFromBundle(flag, bundle);
				removeFromRuns(flag);
				//flag.assetChanged.removeHandler(onFlagAssetChanged);
			}else{
				pendingFlags.splice(index,1);
			}
			delete flags[flag];
		}
		
		protected function assessAllFlags():void{
			for each(var flag:IFrameValidationFlag in pendingFlags){
				assessFlag(flag);
			}
			pendingFlags = new Array();
		}
		/**
		 * Adds this IFrameValidationFlag object into the asset heirarchy.
		 */
		protected function assessFlag(flag:IFrameValidationFlag):void{
			//flag.assetChanged.addHandler(onFlagAssetChanged);
			addToBundle(flag);
			addToRuns(flag);
		}
		/*protected function onFlagAssetChanged(from:IFrameValidationFlag, oldAsset:IDisplayObject):void{
			var oldBundle:AssetBundle = flagToBundle[from];
			var oldRun:DrawRun;
			
			oldRun = findRunForBundle(oldBundle);
			removeFromBundle(from, oldBundle);
			
			var newBundle:AssetBundle = addToBundle(from);
			checkIfRunChange(from, newBundle, oldRun);
		}*/
		protected function addToBundle(flag:IFrameValidationFlag):FlagBundle{
			var bundle:FlagBundle = bundleMap[flag.hierarchyKey];
			if(!bundle){
				bundle = FlagBundle.getNew(flag.hierarchyKey);
				bundle.addValidationFlag(flag);
				bundleMap[flag.hierarchyKey] = bundle;
				//bundle.assetPosChanged.addHandler(onAssetPosChanged);
				addToHeirarchy(bundle);
			}else{
				bundle.addValidationFlag(flag);
			}
			flagToBundle[flag] = bundle;
			return bundle;
		}
		protected function removeFromBundle(flag:IFrameValidationFlag, bundle:FlagBundle):void{
			bundle.removeValidationFlag(flag);
			if(!bundle.validationFlagCount){
				removeFromHeirarchy(bundle);
				delete bundleMap[bundle.key];
				//bundle.assetPosChanged.removeHandler(onAssetPosChanged);
				bundle.release();
			}
			delete flagToBundle[flag];
		}
		/*protected function onAssetPosChanged(bundle:FlagBundle):void{
			var oldRun:DrawRun = findRunForBundle(bundle);
			removeFromHeirarchy(bundle);
			if(bundle.readyForExecution)addToHeirarchy(bundle);
			checkIfRunChange(null, bundle, oldRun);
		}*/
		protected function checkIfRunChange(flag:IFrameValidationFlag, bundle:FlagBundle, oldRun:DrawRun):void{
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
		protected function addToHeirarchy(bundle:FlagBundle):void{
			/*var subject:IDisplayObject = bundle.asset;
			var parentBundle:FlagBundle;
			while(subject && !(parentBundle = bundleMap[subject.parent])){
				subject = subject.parent;
			}*/
			var flag:IFrameValidationFlag = bundle.validationFlags[0];
			var parentBundle:FlagBundle = findParentBundle(flag, rootBundles);
			
			if(parentBundle){
				stealChildren(bundle, parentBundle.children);
				parentBundle.addChild(bundle);
			}else{
				stealChildren(bundle, rootBundles);
				rootBundles.push(bundle);
			}
		}
		protected function findParentBundle(flag:IFrameValidationFlag, inBundles:Array):FlagBundle{
			for each(var parentBundle:FlagBundle in inBundles){
				var parentFlag:IFrameValidationFlag = parentBundle.validationFlags[0];
				if(parentFlag.isDescendant(flag)){
					var nextParent:FlagBundle = findParentBundle(flag, parentBundle.children);
					if(nextParent){
						return nextParent;
					}else{
						return parentBundle;
					}
				}
			}
			return null;
		}
		protected function removeFromHeirarchy(bundle:FlagBundle):void{
			var child:FlagBundle;
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
		protected function stealChildren(bundle:FlagBundle, children:Array):void{
			var bundleFlag:IFrameValidationFlag = bundle.validationFlags[0];
			for(var i:int=0; i<children.length; i++){
				var child:FlagBundle = children[i];
				var childFlag:IFrameValidationFlag = child.validationFlags[0];
				if(bundleFlag.isDescendant(childFlag)){
					bundle.addChild(child);
					children.splice(i,1);
				}
			}
		}
		/*protected function isDescendant(parent:IDisplayObject, child:IDisplayObject):Boolean{
			var subject:IDisplayObject = child.parent;
			while(subject && subject!=parent){
				subject = subject.parent;
			}
			return (subject!=null);
		}*/
		protected function startDrawRun(flag:IFrameValidationFlag):void{
			var childRuns:Array;
			var drawRun:DrawRun;
			if(flag){
				var key:* = flag.hierarchyKey;
				var existingRun:DrawRun;
				childRuns = [];
				if(currentRunCount){
					for each(drawRun in currentRuns){
						var otherKey:* = drawRun.root.key;
						var otherFlag:IFrameValidationFlag = drawRun.root.validationFlags[0];
						if(key==otherKey || otherFlag.isDescendant(flag)){
							existingRun = drawRun;
							break;
						}else if(flag.isDescendant(otherFlag)){
							childRuns.push(drawRun);
						}
					}
				}
				if(existingRun){
					existingRun.forceExecute(flag);
				}else{
					createNewRun(flagToBundle[flag], childRuns);
				}
			}else{
				for each(var bundle:FlagBundle in rootBundles){
					childRuns = [];
					var bundleFlag:IFrameValidationFlag = bundle.validationFlags[0];
					for each(drawRun in currentRuns){
						var runFlag:IFrameValidationFlag = drawRun.root.validationFlags[0];
						if(bundleFlag.isDescendant(runFlag)){
							childRuns.push(drawRun);
						}
					}
					createNewRun(bundle, childRuns);
				}
			}
		}
		protected function createNewRun(bundle:FlagBundle, childRuns:Array):void{
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
			var run:DrawRun = findRunForFlag(flag);
			if(run){
				run.addPending(flag);
			}
		}
		/**
		 * Removed this flag from the applicable running DrawRun
		 */
		protected function removeFromRuns(flag:IFrameValidationFlag):void{
			var run:DrawRun = findRunForFlag(flag);
			if(run){
				run.removePending(flag);
			}
		}
		protected function findRunForFlag(flag:IFrameValidationFlag):DrawRun{
			if(currentRunCount){
				for each(var drawRun:DrawRun in currentRuns){
					var runFlag:IFrameValidationFlag = drawRun.root.validationFlags[0];
					if(runFlag.isDescendant(flag) || runFlag.hierarchyKey==flag.hierarchyKey){
						return drawRun;
					}
				}
			}
			return null;
		}
		protected function findRunForBundle(bundle:FlagBundle):DrawRun{
			if(currentRunCount){
				for each(var drawRun:DrawRun in currentRuns){
					var subject:FlagBundle = bundle;
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

import org.tbyrne.display.validation.IFrameValidationFlag;
import org.tbyrne.hoborg.IPoolable;
import org.tbyrne.hoborg.ObjectPool;

/**
 * A FlagBundle represents a collection of flags which all relate to the same
 * position in the display heirarchy.
 * 
 *  
 * @author Tom
 * 
 */
class FlagBundle implements IPoolable{
	private static const pool:ObjectPool = new ObjectPool(FlagBundle);
	public static function getNew(key:*):FlagBundle{
		var ret:FlagBundle = pool.takeObject();
		//ret.asset = asset;
		ret.key = key;
		return ret;
	}
	
	
	/**
	 * handler(from:AssetBundle)
	 */
	/*public function get assetPosChanged():IAct{
		return _assetPosChanged;
	}*/
	
	public function get validationFlagCount():int{
		return validationFlags.length;
	}
	
	/*public function get asset():IDisplayObject{
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
	}*/
	/*public function get readyForExecution():Boolean{
		return !_asset || _addedToStage;
	}*/
	
	public var key:*;
	public var parent:FlagBundle;
	public var children:Array = new Array();
	public var validationFlags:Array = new Array();
	
	protected var _addedToStage:Boolean;
	/*protected var _asset:IDisplayObject;
	protected var _assetPosChanged:Act = new Act();*/
	
	
	/*protected function onAdded(from:IDisplayObject):void{
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
	}*/
	public function addChild(bundle:FlagBundle):void{
		CONFIG::debug{
			if(children.indexOf(bundle)!=-1){
				Log.error( "AssetBundle.addChild: child already added");
			}
		}
		bundle.parent = this;
		children.push(bundle);
	}
	public function removeChild(bundle:FlagBundle):void{
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
		//asset = null
		validationFlags = new Array();
		parent = null;
		children = new Array();
	}
	public function release():void{
		pool.releaseObject(this);
	}
}
class DrawRun implements IPoolable{
	private static const pool:ObjectPool = new ObjectPool(DrawRun);
	public static function getNew(root:FlagBundle):DrawRun{
		var ret:DrawRun = pool.takeObject();
		ret.root = root;
		return ret;
	}
	
	public var root:FlagBundle;
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
	protected function addFlagsExcept(asset:FlagBundle, except:Dictionary):void{
		if(!except[asset]){
			for each(var flag:IFrameValidationFlag in asset.validationFlags){
				pendingDraws.push(flag);
			}
			for each(var child:FlagBundle in asset.children){
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