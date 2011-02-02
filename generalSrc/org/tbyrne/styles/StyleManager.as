package org.tbyrne.styles
{
	import flash.utils.Dictionary;
	
	import org.openvideoplayer.cc.Style;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.IScopedObjectRoot;
	import org.tbyrne.display.core.ScopedObjectAssigner;
	import org.tbyrne.reflection.ReflectionUtils;

	public class StyleManager implements IScopedObjectRoot
	{
		protected static var _managers:Dictionary = new Dictionary();
		protected static var _scopedObjectAssigner:ScopedObjectAssigner = new ScopedObjectAssigner();
		
		public static function addStyleManager(root:IDisplayObjectContainer):StyleManager{
			var manager:StyleManager = new StyleManager(root);
			_managers[root] = manager;
			_scopedObjectAssigner.addManager(manager);
			return manager;
		}
		public static function removeStyleManager(root:IDisplayObjectContainer):void{
			var manager:StyleManager = _managers[root];
			_scopedObjectAssigner.removeManager(manager);
			delete _managers[root];
			manager.root = null;
		}
		public static function addStylable(stylable:IStylable):void{
			_scopedObjectAssigner.addScopedObject(stylable);
		}
		public static function removeStylable(stylable:IStylable):void{
			_scopedObjectAssigner.removeScopedObject(stylable);
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
		
		// mapped IStylable > StylableBundle
		private var _stylables:Dictionary;
		private var _styles:Vector.<StyleDef>
		
		public function StyleManager(root:IDisplayObjectContainer){
			this.root = root;
			
			_stylables = new Dictionary();
			_styles = new Vector.<StyleDef>();
		}
		
		
		public function addDescendant(descendant:IScopedObject):void{
			var stylable:IStylable = descendant as IStylable;
			stylable.styleNamesChanged.addHandler(onStyleNamesChanged);
			var bundle:StylableBundle = new StylableBundle();
			_stylables[stylable] = bundle;
			assessAllStylesFor(stylable,bundle);
		}
		
		
		public function removeDescendant(descendant:IScopedObject):void{
			var stylable:IStylable = descendant as IStylable;
			stylable.styleNamesChanged.removeHandler(onStyleNamesChanged);
			
			var bundle:StylableBundle = _stylables[stylable];
			for each(var styleDef:StyleDef in bundle.appliedStyles){
				unapplyStyle(stylable,styleDef);
			}

			delete _stylables[stylable];
		}
		
		private function assessAllStylesFor(stylable:IStylable, bundle:StylableBundle):void{
			for each(var styleDef:StyleDef in _styles){
				var appliedIndex:int = bundle.appliedStyles.indexOf(styleDef);
				var shouldBeApplied:Boolean = shouldApply(stylable,styleDef);
				if(shouldBeApplied){
					if(appliedIndex==-1){
						applyStyle(stylable,styleDef);
						bundle.appliedStyles.push(styleDef);
					}
				}else if(appliedIndex!=-1){
					unapplyStyle(stylable,styleDef);
					bundle.appliedStyles.splice(appliedIndex,1);
				}
			}
		}
		
		private function shouldApply(stylable:IStylable, styleDef:StyleDef):Boolean{
			for each(var selector:String in styleDef.selectors){
				if(selectorMatches(stylable,selector)){
					return true;
				}
			}
			return false;
		}
		
		private function selectorMatches(stylable:IStylable, selector:String):Boolean{
			var pipeIndex:int = selector.indexOf("|");
			var className:String;
			var styleName:String;
			if(pipeIndex==-1){
				className = selector;
			}else if(pipeIndex==0){
				styleName = selector.substring(1);
			}else{
				className = selector.substring(0,pipeIndex);
				styleName = selector.substring(pipeIndex+1);
			}
			var classMatch:Boolean;
			if(className){
				var klass:Class = ReflectionUtils.getClassByName(className);
				classMatch = stylable is klass;
			}else{
				classMatch = true;
			}
			var styleMatch:Boolean = (!styleName || (stylable.styleNames.indexOf(styleName)!=-1));
			return (classMatch && styleMatch);
		}
		
		
		private function applyStyle(stylable:IStylable, styleDef:StyleDef):void{
			for(var i:String in styleDef.values){
				stylable.applyStyle(i,styleDef.values[i]);
			}
		}
		private function unapplyStyle(stylable:IStylable, styleDef:StyleDef):void{
			for(var i:String in styleDef.values){
				stylable.clearStyle(i);
			}
		}
		
		private function onStyleNamesChanged(from:IStylable):void{
			assessAllStylesFor(from,_stylables[from])
		}
		
		
		public function addStyleDef(styleDef:StyleDef):void{
			_styles.push(styleDef);
			
			for(var i:* in _stylables){
				var stylable:IStylable = (i as IStylable);
				var bundle:StylableBundle = _stylables[stylable];
				var shouldBeApplied:Boolean = shouldApply(stylable,styleDef);
				if(shouldBeApplied){
					applyStyle(stylable,styleDef);
					bundle.appliedStyles.push(styleDef);
				}
			}
		}
		public function removeStyleDef(styleDef:StyleDef):void{
			var index:int = _styles.indexOf(styleDef);
			_styles.splice(index,1);
			
			for(var i:* in _stylables){
				var stylable:IStylable = (i as IStylable);
				var bundle:StylableBundle = _stylables[stylable];
				var appliedIndex:int = bundle.appliedStyles.indexOf(styleDef);
				if(appliedIndex!=-1){
					unapplyStyle(stylable,styleDef);
					bundle.appliedStyles.splice(appliedIndex,1);
				}
			}
		}
	}
}
import org.tbyrne.styles.StyleDef;

// TODO: pool StylableBundle
class StylableBundle{
	public var appliedStyles:Vector.<StyleDef> = new Vector.<StyleDef>();
}