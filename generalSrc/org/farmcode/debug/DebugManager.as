package org.farmcode.debug
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.IApplication;
	import org.farmcode.debug.display.DebugDisplay;
	import org.farmcode.debug.nodeTypes.IDebugNode;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;
	import org.farmcode.display.assets.schema.StandardAssetSchema;
	import org.farmcode.debug.display.assets.DebugAssetFactory;
	import org.farmcode.display.core.IScopedObject;
	import org.farmcode.display.core.IScopedObjectRoot;
	import org.farmcode.display.core.ScopedObjectAssigner;

	public class DebugManager implements IApplication, IScopedObjectRoot
	{
		protected static var _managers:Dictionary = new Dictionary();
		protected static var _scopedObjectAssigner:ScopedObjectAssigner = new ScopedObjectAssigner();
		protected static var _assetFactory:DebugAssetFactory = new DebugAssetFactory(new StandardAssetSchema());
		
		public static function addApplication(app:IApplication):IApplication{
			var manager:DebugManager = new DebugManager(_assetFactory.getCoreSkin(AssetNames.DEBUG_DISPLAY),app);
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
		
		public function get scope():IDisplayAsset{
			return _debugDisplay.scope;
		}
		public function set scope(value:IDisplayAsset):void{
			_debugDisplay.scope = value;
		}
		public function set container(value:IContainerAsset):void{
			if(_container != value){
				if(_container)_container.removeAsset(_debugDisplay.asset);
				_container = value;
				if(_container)_container.addAsset(_debugDisplay.asset);
			}
		}
		
		protected var _scopeChanged:Act;
		private var _application:IApplication;
		private var _container:IContainerAsset;
		private var _debugDisplay:DebugDisplay;
		
		public function DebugManager(asset:IAsset=null, application:IApplication=null){
			_debugDisplay = new DebugDisplay(asset as IDisplayAsset); // testing asset
			_debugDisplay.scopeChanged.addHandler(onScopeChanged);
			this.application = application;
		}
		public function addDescendant(descendant:IScopedObject):void{
			_debugDisplay.addDebugNode(descendant as IDebugNode);
		}
		public function removeDescendant(descendant:IScopedObject):void{
			_debugDisplay.removeDebugNode(descendant as IDebugNode);
		}
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			_debugDisplay.setDisplayPosition(x, y, width, height);
		}
		public function onScopeChanged(from:DebugDisplay, oldScope:IDisplayAsset):void{
			if(_scopeChanged)_scopeChanged.perform(this,oldScope);
		}
	}
}