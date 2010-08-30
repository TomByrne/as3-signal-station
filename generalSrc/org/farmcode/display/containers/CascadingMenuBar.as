package org.farmcode.display.containers
{
	import flash.utils.Dictionary;
	
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.relative.RelativeLayout;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.instanceFactory.SimpleInstanceFactory;
	
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
		
		
		protected var _assumedListAsset:IDisplayAsset;
		protected var _assumedListFactory:SimpleInstanceFactory;
		protected var _listFactory:IInstanceFactory;
		protected var _currListFactory:IInstanceFactory;
		protected var _rootWatcher:ListWatcher;
		
		
		public function CascadingMenuBar(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			_layout.pixelFlow = true;
			_layout.flowDirection = Direction.HORIZONTAL;
			
			_rootWatcher = new ListWatcher(Anchor.BOTTOM);
			_rootWatcher.parentList = this;
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_assumedListAsset = _containerAsset.takeAssetByName(AssetNames.CHILD_LIST,IDisplayAsset,true);
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
		protected function createAssumedListFactory(asset:IDisplayAsset):SimpleInstanceFactory{
			var factory:SimpleInstanceFactory = new SimpleInstanceFactory(ListBox);
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
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import org.farmcode.data.dataTypes.IDataProvider;
import org.farmcode.display.DisplayNamespace;
import org.farmcode.display.constants.Anchor;
import org.farmcode.display.containers.AbstractSelectableList;
import org.farmcode.display.controls.popout.PopoutDisplay;
import org.farmcode.display.core.ILayoutView;
import org.farmcode.display.layout.ILayoutSubject;
import org.farmcode.display.layout.grid.RendererGridLayout;
import org.farmcode.display.scrolling.ScrollMetrics;
import org.farmcode.instanceFactory.IInstanceFactory;

use namespace DisplayNamespace;
class ListWatcher{
	public function get parentList():AbstractSelectableList{
		return _parentList;
	}
	public function set parentList(value:AbstractSelectableList):void{
		if(_parentList!=value){
			if(_parentList){
				_parentList.rendererFactory = null;
				
				_parentList.selectionChangeAct.removeHandler(onSelectionChange);
				_parentList.layout.positionChanged.removeHandler(onListPosChanged);
				_parentList.scrollMetricsChanged.removeHandler(onListScroll);
			}
			_parentList = value;
			if(_parentList){
				_parentList.rendererFactory = _rendererFactory;
				
				_parentList.selectionChangeAct.addHandler(onSelectionChange);
				_parentList.layout.positionChanged.addHandler(onListPosChanged);
				_parentList.scrollMetricsChanged.addHandler(onListScroll);
				
				_childDataIndex = _parentList.selectedIndex;
				
				if(_childDataIndex==-1)_hideChildList();
				else showChildList();
				
			}else{
				_popoutDisplay.popoutShown = false;
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
	
	private var _rendererFactory:IInstanceFactory;
	private var _listFactory:IInstanceFactory;
	private var _parentList:AbstractSelectableList;
	private var _childListWatcher:ListWatcher;
	private var _childDataIndex:int;
	protected var _popoutDisplay:PopoutDisplay;
	protected var _rendPos:Rectangle;
	
	public function ListWatcher(anchor:String, listFactory:IInstanceFactory=null){
		_popoutDisplay = new PopoutDisplay();
		_popoutDisplay.popoutAnchor = anchor;
		this.parentList = parentList;
		this.listFactory = listFactory;
	}
	protected function onListPosChanged(layout:RendererGridLayout, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number) : void{
		assessRelative();
	}
	protected function onListScroll(listBox:AbstractSelectableList, direction:String, metrics:ScrollMetrics) : void{
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
		var childData:IDataProvider = _parentList.layout.getDataAt(_childDataIndex);
		if(childData && childData.data){
			if(!_popoutDisplay.popoutShown){
				if(!_childListWatcher){
					_childListWatcher = new ListWatcher(Anchor.BOTTOM_RIGHT, _listFactory);
					_childListWatcher.rendererFactory = _rendererFactory;
				}
				if(!_childListWatcher.parentList){
					_childListWatcher.parentList = _listFactory.createInstance();
					_popoutDisplay.popout = _childListWatcher.parentList;
				}
				var renderer:ILayoutSubject = _parentList.layout.getRenderer(_childDataIndex);
				_popoutDisplay.relativeTo = renderer as ILayoutView;
				_childListWatcher.parentList.dataProvider = childData.data;
				_popoutDisplay.popoutShown = true;
			}
			assessRelative();
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
			_popoutDisplay.popoutShown = false;
			_popoutDisplay.relativeTo = null;
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
		if(!_rendPos)_rendPos = new Rectangle();
		var layoutPos:Rectangle = _parentList.layout.displayPosition;
		var dataPos:Rectangle = _parentList.layout.getDataPosition(_childDataIndex,_rendPos);
		
	}
}