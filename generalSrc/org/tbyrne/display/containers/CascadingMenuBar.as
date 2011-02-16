package org.tbyrne.display.containers
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.AssetNames;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.controls.MenuBarRenderer;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.instanceFactory.IInstanceFactory;
	import org.tbyrne.instanceFactory.SimpleInstanceFactory;
	
	use namespace DisplayNamespace;
	
	public class CascadingMenuBar extends AbstractSelectableList
	{
		public function get listFactory():IInstanceFactory{
			return _listFactory;
		}
		public function set listFactory(value:IInstanceFactory):void{
			if(_listFactory != value){
				_listFactory = value;
				assessFactory();
			}
		}
		override public function set rendererFactory(value:IInstanceFactory):void{
			super.rendererFactory = value;
			_rootWatcher.rendererFactory = value;
		}
		public function get gap():Number{
			return _layout.gap;
		}
		public function set gap(value:Number):void{
			_layout.gap = value;
		}
		
		public function get clickAutoClose():Boolean{
			return _rootWatcher.clickAutoClose;
		}
		public function set clickAutoClose(value:Boolean):void{
			if(_rootWatcher.clickAutoClose!=value){
				_rootWatcher.clickAutoClose = value;
			}
		}
		
		private var _clickAutoClose:Boolean;
		
		protected var _assumedListAsset:IDisplayObject;
		protected var _assumedListFactory:SimpleInstanceFactory;
		protected var _listFactory:IInstanceFactory;
		protected var _currListFactory:IInstanceFactory;
		protected var _rootWatcher:ListWatcher;
		
		
		public function CascadingMenuBar(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			_layout.pixelFlow = true;
			_layout.flowDirection = Direction.HORIZONTAL;
			_layout.equaliseCellHeights = true;
			
			_rootWatcher = new ListWatcher(Anchor.BOTTOM, true);
			_rootWatcher.parentList = this;
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_assumedListAsset = _containerAsset.takeAssetByName(AssetNames.CHILD_LIST,true);
			if(_assumedListAsset){
				_containerAsset.removeAsset(_assumedListAsset);
				assessListFactory();
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			if(_assumedListAsset){
				_containerAsset.addAsset(_assumedListAsset);
				_containerAsset.returnAsset(_assumedListAsset);
				_assumedListAsset = null;
				
				if(_assumedListFactory){
					_assumedListFactory.instanceProperties = null;
					_assumedListFactory = null;
					assessListFactory();
				}
			}
		}
		override protected function getAssumedRendererClass():Class{
			return MenuBarRenderer;
		}
		protected function assessListFactory():void{
			var factory:IInstanceFactory;
			if(_listFactory){
				factory = _listFactory;
			}else if(_assumedListAsset){
				if(!_assumedListFactory){
					_assumedListFactory = createAssumedListFactory(_assumedListAsset);
				}
				factory = _assumedListFactory;
			}else{
				factory = null;
			}
			if(factory!=_currListFactory){
				updateListFactory(factory);
			}
		}
		protected function createAssumedListFactory(asset:IDisplayObject):SimpleInstanceFactory{
			var factory:SimpleInstanceFactory = new SimpleInstanceFactory(CascadingListBox);
			factory.useChildFactories = true;
			factory.instanceProperties = new Dictionary();
			factory.instanceProperties["asset"] = asset.getCloneFactory();
			return factory;
		}
		protected function updateListFactory(factory:IInstanceFactory):void{
			_currListFactory = factory;
			_rootWatcher.listFactory = factory;
		}
		override protected function updateFactory(factory:IInstanceFactory, dataField:String):void{
			super.updateFactory(factory, dataField);
			// update child lists if not the assumed factory
		}
	}
}
import flash.utils.Dictionary;

import org.tbyrne.data.dataTypes.IDataProvider;
import org.tbyrne.display.DisplayNamespace;
import org.tbyrne.display.actInfo.IMouseActInfo;
import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
import org.tbyrne.display.assets.utils.isDescendant;
import org.tbyrne.display.constants.Anchor;
import org.tbyrne.display.constants.Direction;
import org.tbyrne.display.containers.AbstractSelectableList;
import org.tbyrne.display.containers.ICascadingMenuBarRenderer;
import org.tbyrne.display.containers.ListBox;
import org.tbyrne.display.controls.MenuBarRenderer;
import org.tbyrne.display.controls.popout.PopoutDisplay;
import org.tbyrne.display.core.ILayoutView;
import org.tbyrne.display.layout.ILayout;
import org.tbyrne.display.layout.ILayoutSubject;
import org.tbyrne.display.scrolling.IScrollMetrics;
import org.tbyrne.instanceFactory.IInstanceFactory;

use namespace DisplayNamespace;
class ListWatcher{
	public function get parentList():AbstractSelectableList{
		return _parentList;
	}
	public function set parentList(value:AbstractSelectableList):void{
		if(_parentList!=value){
			if(_parentList){
				_parentList.rendererFactory = null;
				
				_parentList.layout.addRendererAct.removeHandler(onAddRenderer);
				_parentList.layout.removeRendererAct.removeHandler(onRemoveRenderer);
				
				_parentList.selectionChangeAct.removeHandler(onSelectionChange);
				//_parentList.layout.positionChanged.removeHandler(onListPosChanged);
				_parentList.getScrollMetrics(Direction.HORIZONTAL).scrollMetricsChanged.removeHandler(onListScroll);
				_parentList.getScrollMetrics(Direction.VERTICAL).scrollMetricsChanged.removeHandler(onListScroll);
			}
			_parentList = value;
			if(_parentList){
				_parentList.rendererFactory = _rendererFactory;
				
				_parentList.selectionChangeAct.addHandler(onSelectionChange);
				//_parentList.layout.positionChanged.addHandler(onListPosChanged);
				_parentList.getScrollMetrics(Direction.HORIZONTAL).scrollMetricsChanged.addHandler(onListScroll);
				_parentList.getScrollMetrics(Direction.VERTICAL).scrollMetricsChanged.addHandler(onListScroll);
				
				_parentList.layout.addRendererAct.addHandler(onAddRenderer);
				_parentList.layout.removeRendererAct.addHandler(onRemoveRenderer);
				
				_childDataIndex = _parentList.selectedIndex;
				
				if(_childDataIndex==-1)_hideChildList();
				else showChildList();
				
			}else{
				_popoutDisplay.popoutShown = false;
			}
		}
	}
	
	
	public function get clickAutoClose():Boolean{
		return _clickAutoClose;
	}
	public function set clickAutoClose(value:Boolean):void{
		_clickAutoClose = value;
		if(_childListWatcher)_childListWatcher.clickAutoClose = value;
		if(_popoutDisplay.popoutShown){
			if(_clickAutoClose){
				addClickAutoCloseListener();
			}else{
				removeClickAutoCloseListener();
			}
		}
	}
	
	public function get listFactory():IInstanceFactory{
		return _listFactory;
	}
	public function set listFactory(value:IInstanceFactory):void{
		if(_listFactory!=value){
			_listFactory = value;
			if(_childListWatcher){
				var wasShown:Boolean = _childListWatcher.shown;
				releaseChildList();
				if(wasShown)showChildList();
			}
		}
	}
	public function get rendererFactory():IInstanceFactory{
		return _rendererFactory;
	}
	public function set rendererFactory(value:IInstanceFactory):void{
		if(_rendererFactory!=value){
			_rendererFactory = value;
			if(_parentList){
				_parentList.rendererFactory = _rendererFactory;
			}
			if(_childListWatcher){
				_childListWatcher.rendererFactory = _rendererFactory;
			}
		}
	}
	
	public function get shown():Boolean{
		return _popoutDisplay.popoutShown;
	}
	
	private var _isTopWatcher:Boolean;
	private var _isMenuOpen:Boolean;
	private var _rendererFactory:IInstanceFactory;
	private var _listFactory:IInstanceFactory;
	private var _parentList:AbstractSelectableList;
	private var _childListWatcher:ListWatcher;
	private var _childDataIndex:int;
	protected var _popoutDisplay:PopoutDisplay;
	private var _clickAutoClose:Boolean = true;
	private var _renderers:Vector.<ICascadingMenuBarRenderer>;
	private var _listeningToStage:Boolean;
	
	public function ListWatcher(anchor:String, isTopWatcher:Boolean, listFactory:IInstanceFactory=null){
		_popoutDisplay = new PopoutDisplay();
		_popoutDisplay.popoutAnchor = anchor;
		this.parentList = parentList;
		this.listFactory = listFactory;
		_isTopWatcher = isTopWatcher;
	}
	protected function onAddRenderer(layout:ILayout, renderer:ILayoutSubject):void{
		var castRenderer:ICascadingMenuBarRenderer = (renderer as ICascadingMenuBarRenderer);
		if(castRenderer){
			if(!_renderers)_renderers = new Vector.<ICascadingMenuBarRenderer>();
			_renderers.push(castRenderer);
			castRenderer.isMenuOpen = _isMenuOpen;
		}
	}
	protected function onRemoveRenderer(layout:ILayout, renderer:ILayoutSubject):void{
		if(_renderers){
			var index:int = _renderers.indexOf(renderer);
			if(index!=-1){
				_renderers.splice(index,1);
			}
		}
	}
	internal function setIsMenuOpen(value:Boolean) : void{
		_isMenuOpen = value;
		for each(var renderer:ICascadingMenuBarRenderer in _renderers){
			renderer.isMenuOpen = value;
		}
		if(_childListWatcher)_childListWatcher.setIsMenuOpen(_isMenuOpen);
	}
	protected function onListScroll(from:IScrollMetrics) : void{
		assessRelative();
	}
	protected function onSelectionChange(listBox:AbstractSelectableList, selectedIndices:Array, selectedData:Dictionary) : void{
		if(selectedIndices.length){
			_childDataIndex = selectedIndices[0];
			showChildList();
		}else{
			_hideChildList();
		}
	}
	protected function showChildList() : void{
		var childData:IDataProvider = _parentList.layout.getDataAt(_childDataIndex) as IDataProvider;
		if(childData && childData.data){
			
			if(!_popoutDisplay.popoutShown || childData.data!=_childListWatcher.parentList.dataProvider){
				if(!_childListWatcher){
					_childListWatcher = new ListWatcher(Anchor.BOTTOM_RIGHT, false, _listFactory);
					_childListWatcher.rendererFactory = _rendererFactory;
					_childListWatcher.clickAutoClose = _clickAutoClose;
					_childListWatcher.setIsMenuOpen(_isMenuOpen);
				}
				if(!_childListWatcher.parentList){
					_childListWatcher.parentList = _listFactory.createInstance();
					_popoutDisplay.popout = _childListWatcher.parentList;
				}
				var renderer:ILayoutSubject = _parentList.layout.getRenderer(_childDataIndex);
				_popoutDisplay.relativeTo = renderer as ILayoutView;
				_childListWatcher.parentList.dataProvider = childData.data;
				_popoutDisplay.popoutShown = true;
				
				
				if(_clickAutoClose)addClickAutoCloseListener();
				
				if(_isTopWatcher){
					setIsMenuOpen(true);
				}
			}
		}else{
			_hideChildList();
		}
	}
	
	internal function hideChildList() : void{
		_parentList.selectedIndex = -1;
	}
	internal function _hideChildList() : void{
		if(_popoutDisplay.popoutShown){
			if(_childListWatcher){
				_childListWatcher.hideChildList();
			}
			if(_clickAutoClose)removeClickAutoCloseListener();
			_popoutDisplay.popoutShown = false;
			_popoutDisplay.relativeTo = null;
			if(_isTopWatcher){
				setIsMenuOpen(false);
			}
		}
	}
	protected function releaseChildList():void{
		hideChildList();
		_childListWatcher.release();
		_popoutDisplay.popout = null;
	}
	protected function release():void{
		releaseChildList();
		parentList = null;
	}
	protected function assessRelative():void{
		if(_childDataIndex!=-1)_popoutDisplay.relativeTo = _parentList.layout.getRenderer(_childDataIndex) as ILayoutView;
		else _popoutDisplay.relativeTo = null;
	}
	
	
	
	protected function addClickAutoCloseListener():void{
		if(!_listeningToStage){
			_listeningToStage = true;
			parentList.asset.stage.mousePressed.addHandler(onStageClicked);
		}
	}
	protected function removeClickAutoCloseListener():void{
		if(_listeningToStage){
			_listeningToStage = false;
			parentList.asset.stage.mousePressed.removeHandler(onStageClicked);
		}
	}
	protected function onStageClicked(from:IInteractiveObject, info:IMouseActInfo):void{
		var parentAsset:IDisplayObjectContainer = _parentList.asset as IDisplayObjectContainer;
		var childAsset:IDisplayObjectContainer = _childListWatcher.parentList.asset as IDisplayObjectContainer;
		if(info.mouseTarget!=parentAsset && !parentAsset.contains(info.mouseTarget) &&
			info.mouseTarget!=childAsset && !childAsset.contains(info.mouseTarget)){
			hideChildList();
		}
	}
}
class CascadingListBox extends ListBox{
	override protected function getAssumedRendererClass():Class{
		return MenuBarRenderer;
	}
}