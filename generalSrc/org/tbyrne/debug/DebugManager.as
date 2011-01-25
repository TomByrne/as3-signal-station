package org.tbyrne.debug
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.IApplication;
	import org.tbyrne.debug.display.DebugDisplay;
	import org.tbyrne.debug.display.assets.DebugAssetFactory;
	import org.tbyrne.debug.nodeTypes.IDebugNode;
	import org.tbyrne.display.assets.AssetNames;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.schema.StandardAssetSchema;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.IScopedObjectRoot;
	import org.tbyrne.display.core.ScopedObjectAssigner;

	public class DebugManager implements IApplication, IScopedObjectRoot
	{
		protected static var _managers:Dictionary = new Dictionary();
		protected static var _scopedObjectAssigner:ScopedObjectAssigner = new ScopedObjectAssigner();
		protected static var _assetFactory:DebugAssetFactory = new DebugAssetFactory(new StandardAssetSchema());
		
		public static function addApplication(app:IApplication):IApplication{
			var manager:DebugManager;
			CONFIG::debug{
				manager = new DebugManager(_assetFactory.getCoreSkin(AssetNames.DEBUG_DISPLAY),app);
			}
			_managers[app] = manager;
			_scopedObjectAssigner.addManager(manager);
			return manager;
		}
		public static function removeApplication(app:IApplication):void{
			var manager:DebugManager = _managers[app];
			_scopedObjectAssigner.removeManager(manager);
			delete _managers[app];
			manager.application = null;
		}
		public static function addDebugNode(debugNode:IDebugNode):void{
			_scopedObjectAssigner.addScopedObject(debugNode);
		}
		public static function removeDebugNode(debugNode:IDebugNode):void{
			_scopedObjectAssigner.removeScopedObject(debugNode);
		}
		
		
		public function get application():IApplication{
			return _application;
		}
		public function set application(value:IApplication):void{
			if(_application!=value){
				_application = value;
				_debugDisplay.application = value;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			if(!_scopeChanged)_scopeChanged = new Act();
			return _scopeChanged;
		}
		
		public function get scope():IDisplayObject{
			return _debugDisplay.scope;
		}
		public function set scope(value:IDisplayObject):void{
			_debugDisplay.scope = value;
		}
		public function set container(value:IDisplayObjectContainer):void{
			if(_container != value){
				if(_container)_container.removeAsset(_debugDisplay.asset);
				_container = value;
				if(_container)_container.addAsset(_debugDisplay.asset);
			}
		}
		
		protected var _scopeChanged:Act;
		private var _application:IApplication;
		private var _container:IDisplayObjectContainer;
		private var _debugDisplay:DebugDisplay;
		
		public function DebugManager(asset:IAsset=null, application:IApplication=null){
			_debugDisplay = new DebugDisplay(asset as IDisplayObject); // testing asset
			_debugDisplay.scopeChanged.addHandler(onScopeChanged);
			this.application = application;
		}
		public function addDescendant(descendant:IScopedObject):void{
			_debugDisplay.addDebugNode(descendant as IDebugNode);
		}
		public function removeDescendant(descendant:IScopedObject):void{
			_debugDisplay.removeDebugNode(descendant as IDebugNode);
		}
		public function setPosition(x:Number, y:Number):void{
			_debugDisplay.setPosition(x, y);
		}
		public function setSize(width:Number, height:Number):void{
			_debugDisplay.setSize(width, height);
		}
		public function onScopeChanged(from:DebugDisplay, oldScope:IDisplayObject):void{
			if(_scopeChanged)_scopeChanged.perform(this,oldScope);
		}
	}
}