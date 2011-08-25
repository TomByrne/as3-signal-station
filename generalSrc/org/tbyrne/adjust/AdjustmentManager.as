package org.tbyrne.adjust
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.IScopedObjectRoot;
	import org.tbyrne.display.core.ScopedObjectAssigner;
	import org.tbyrne.reflection.ReflectionUtils;

	public class AdjustmentManager implements IScopedObjectRoot
	{
		protected static var _managers:Dictionary = new Dictionary();
		protected static var _scopedObjectAssigner:ScopedObjectAssigner = new ScopedObjectAssigner();
		
		public static function addAdjustmentManager(root:IDisplayObjectContainer):AdjustmentManager{
			var manager:AdjustmentManager = new AdjustmentManager(root);
			_managers[root] = manager;
			_scopedObjectAssigner.addManager(manager);
			return manager;
		}
		public static function removeAdjustmentManager(root:IDisplayObjectContainer):void{
			var manager:AdjustmentManager = _managers[root];
			_scopedObjectAssigner.removeManager(manager);
			delete _managers[root];
			manager.root = null;
		}
		public static function addAdjustable(adjustable:IScopedObject):void{
			_scopedObjectAssigner.addScopedObject(adjustable);
		}
		public static function removeAdjustable(adjustable:IScopedObject):void{
			_scopedObjectAssigner.removeScopedObject(adjustable);
		}
		
		
		
		
		
		
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			return (_scopeChanged || (_scopeChanged = new Act()));
		}
		
		protected var _scopeChanged:Act;
		
		
		public function get scope():IDisplayObject{
			return root;
		}
		public function set scope(value:IDisplayObject):void{
			root = (value as IDisplayObjectContainer);
		}
		public function get root():IDisplayObjectContainer{
			return _root;
		}
		public function set root(value:IDisplayObjectContainer):void{
			if(_root!=value){
				_root = value;
				if(_scopeChanged)_scopeChanged.perform(this);
			}
		}
		
		private var _root:IDisplayObjectContainer;
		
		// mapped IStylable > AdjustmentBundle
		private var _adjustables:Dictionary;
		private var _adjustments:Vector.<Adjustment>
		
		public function AdjustmentManager(root:IDisplayObjectContainer=null){
			this.root = root;
			
			_adjustables = new Dictionary();
			_adjustments = new Vector.<Adjustment>();
		}
		
		
		public function addDescendant(descendant:IScopedObject):void{
			addAdjustable(descendant as IAdjustable);
		}
		
		public function addAdjustable(adjustable:IAdjustable):void{
			adjustable.adjustNamesChanged.addHandler(onAdjustableNamesChanged);
			var bundle:AdjustmentBundle = new AdjustmentBundle();
			_adjustables[adjustable] = bundle;
			assessAllStylesFor(adjustable,bundle);
		}
		
		
		public function removeDescendant(descendant:IScopedObject):void{
			removeAdjustable(descendant as IAdjustable);
		}
		public function removeAdjustable(adjustable:IAdjustable):void{
			adjustable.adjustNamesChanged.removeHandler(onAdjustableNamesChanged);
			
			var bundle:AdjustmentBundle = _adjustables[adjustable];
			for each(var adjustment:Adjustment in bundle.appliedAdjustments){
				unapplyAdjustment(adjustable,adjustment);
			}
			
			delete _adjustables[adjustable];
		}
		
		private function assessAllStylesFor(adjustable:IAdjustable, bundle:AdjustmentBundle):void{
			for each(var adjustment:Adjustment in _adjustments){
				var appliedIndex:int = bundle.appliedAdjustments.indexOf(adjustment);
				var shouldBeApplied:Boolean = shouldApply(adjustable,adjustment);
				if(shouldBeApplied){
					if(appliedIndex==-1){
						applyAdjustment(adjustable,adjustment);
						bundle.appliedAdjustments.push(adjustment);
					}
				}else if(appliedIndex!=-1){
					unapplyAdjustment(adjustable,adjustment);
					bundle.appliedAdjustments.splice(appliedIndex,1);
				}
			}
		}
		
		private function shouldApply(adjustable:IAdjustable, adjustment:Adjustment):Boolean{
			for each(var selector:String in adjustment.selectors){
				if(selectorMatches(adjustable,selector)){
					return true;
				}
			}
			return false;
		}
		
		private function selectorMatches(adjustable:IAdjustable, selector:String):Boolean{
			var pipeIndex:int = selector.indexOf("|");
			var className:String;
			var adjustName:String;
			if(pipeIndex==-1){
				className = selector;
			}else if(pipeIndex==0){
				adjustName = selector.substring(1);
			}else{
				className = selector.substring(0,pipeIndex);
				adjustName = selector.substring(pipeIndex+1);
			}
			var classMatch:Boolean;
			if(className){
				var klass:Class = ReflectionUtils.getClassByName(className);
				classMatch = adjustable.adjustDest is klass;
			}else{
				classMatch = true;
			}
			var match:Boolean = (!adjustName || (adjustable.adjustNames && adjustable.adjustNames.indexOf(adjustName)!=-1));
			return (classMatch && match);
		}
		
		
		private function applyAdjustment(adjustable:IAdjustable, adjustment:Adjustment):void{
			for(var i:String in adjustment.values){
				adjustable.applyAdjustment(i,adjustment.values[i]);
			}
		}
		private function unapplyAdjustment(adjustable:IAdjustable, adjustment:Adjustment):void{
			for(var i:String in adjustment.values){
				adjustable.clearAdjustment(i);
			}
		}
		
		private function onAdjustableNamesChanged(from:IAdjustable):void{
			assessAllStylesFor(from,_adjustables[from])
		}
		
		
		public function addAdjustment(adjustment:Adjustment):void{
			_adjustments.push(adjustment);
			
			for(var i:* in _adjustables){
				var adjustable:IAdjustable = (i as IAdjustable);
				var bundle:AdjustmentBundle = _adjustables[adjustable];
				var shouldBeApplied:Boolean = shouldApply(adjustable,adjustment);
				if(shouldBeApplied){
					applyAdjustment(adjustable,adjustment);
					bundle.appliedAdjustments.push(adjustment);
				}
			}
		}
		public function removeAdjustment(adjustment:Adjustment):void{
			var index:int = _adjustments.indexOf(adjustment);
			_adjustments.splice(index,1);
			
			for(var i:* in _adjustables){
				var adjustable:IAdjustable = (i as IAdjustable);
				var bundle:AdjustmentBundle = _adjustables[adjustable];
				var appliedIndex:int = bundle.appliedAdjustments.indexOf(adjustment);
				if(appliedIndex!=-1){
					unapplyAdjustment(adjustable,adjustment);
					bundle.appliedAdjustments.splice(appliedIndex,1);
				}
			}
		}
	}
}
import org.tbyrne.adjust.Adjustment;

// TODO: pool AdjustmentBundle
class AdjustmentBundle{
	public var appliedAdjustments:Vector.<Adjustment> = new Vector.<Adjustment>();
}