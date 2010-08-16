package org.farmcode.display.controls.popout {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.utils.isDescendant;
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.containers.ListBox;
	import org.farmcode.display.controls.Control;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	/**
	 * The PopoutList class forms the base functionality for both DropDownLists
	 * and ComboBoxes. It is comprised of a togglable button which, when selected,
	 * displays a list of options.
	 */
	public class PopoutList extends Control {
		
		private var LIST_CHILD:String = "list";
		
		
		public function get rendererFactory():IInstanceFactory {
			return _listBox.rendererFactory;
		}
		
		public function set rendererFactory(value:IInstanceFactory):void {
			_listBox.rendererFactory=value;
		}
		
		public function get listAnchor():String {
			return _listAnchor;
		}
		
		public function set listAnchor(value:String):void {
			if(_listAnchor!=value) {
				_listAnchor=value;
				invalidate();
			}
		}
		
		public function get maxListHeight():Number{
			return _popoutDisplay.popoutLayoutInfo.maxHeight;
		}
		public function set maxListHeight(value:Number):void{
			_popoutDisplay.popoutLayoutInfo.maxHeight = value;
		}
		
		protected var _listAnchor:String = Anchor.BOTTOM;
		protected var _popoutDisplay:PopoutDisplay;
		protected var _listBox:ListBox;
		
		public function PopoutList(asset:IDisplayAsset=null) {
			super(asset);
			_popoutDisplay=new PopoutDisplay();
			_popoutDisplay.popoutOpen.addHandler(onPopoutOpen);
			_popoutDisplay.popoutClose.addHandler(onPopoutClose);
			_listBox=new ListBox();
			_listBox.measurementsChanged.addHandler(onListMeasureChange);
			_popoutDisplay.popout = _listBox;
		}
		protected function onPopoutOpen(popoutDisplay:PopoutDisplay, popout:ListBox):void {
			if(closeOnClickOutside()){
				asset.stage.mouseReleased.addHandler(onMouseDown);
			}
		}
		protected function onPopoutClose(popoutDisplay:PopoutDisplay, popout:ListBox):void {
			if(closeOnClickOutside()){
				asset.stage.mouseReleased.removeHandler(onMouseDown);
			}
		}
		protected function onMouseDown(from:IInteractiveObjectAsset, info:IMouseActInfo):void {
			if(info.mouseTarget!=asset && !isDescendant(_containerAsset,info.mouseTarget) &&
				info.mouseTarget!=_listBox.asset && !isDescendant(_listBox.asset as IContainerAsset,info.mouseTarget)){
				_popoutDisplay.popoutShown = false;
			}
		}
		override protected function bindToAsset():void {
			_popoutDisplay.relativeTo=asset;
			var listAsset:IDisplayAsset = _containerAsset.takeAssetByName(LIST_CHILD,IDisplayAsset);
			_containerAsset.removeAsset(listAsset);
			_listBox.asset=listAsset;
			super.bindToAsset();
		}
		
		override protected function unbindFromAsset():void {
			super.unbindFromAsset();
			_popoutDisplay.relativeTo=null;
			var listAsset:IAsset = _listBox.asset;
			_containerAsset.addAsset(_listBox.asset);
			_listBox.asset=null;
		}
		
		override protected function measure():void {
			var alignArea:Rectangle = getListAlignMeas();
			var listMeas:Point = _listBox.measurements;
			switch(_listAnchor){
				case Anchor.TOP:
				case Anchor.CENTER:
				case Anchor.BOTTOM:
					if(alignArea.width>listMeas.x){
						_measurements.x = alignArea.width;
					}else{
						_measurements.x = listMeas.x;
					}
					break;
				default:
					_measurements.x = alignArea.width+listMeas.x;
					break;
			}
			_measurements.y = alignArea.height;
		}
		override protected function draw():void {
			var listMeas:Point = _listBox.measurements;
			var alignArea:Rectangle = getListAlignArea();
			var useRect:Boolean = (alignArea!=null);
			var x:Number;
			var y:Number;
			var minListWidth:Number;
			switch(_listAnchor){
				case Anchor.TOP:
				case Anchor.TOP_LEFT:
				case Anchor.TOP_RIGHT:
					if(useRect){
						y = alignArea.top-listMeas.y;
						minListWidth = alignArea.width;
					}else{
						y = -listMeas.y;
					}
					break;
				case Anchor.BOTTOM:
				case Anchor.BOTTOM_LEFT:
				case Anchor.BOTTOM_RIGHT:
					if(useRect){
						y = alignArea.bottom;
						minListWidth = alignArea.width;
					}else{
						y = 0;
					}
					break;
				default:
					if(useRect){
						if(_listAnchor==Anchor.CENTER){
							minListWidth = alignArea.width;
						}
						y = (alignArea.y+alignArea.height/2)-(listMeas.y/2);
					}else{
						y = 0;
					}
			}
			switch(_listAnchor){
				case Anchor.LEFT:
				case Anchor.TOP_LEFT:
				case Anchor.BOTTOM_LEFT:
					if(useRect){
						x = alignArea.left-listMeas.x;
					}else{
						x = -listMeas.x;
					}
					break;
				case Anchor.RIGHT:
				case Anchor.TOP_RIGHT:
				case Anchor.BOTTOM_RIGHT:
					if(useRect){
						x = alignArea.right;
					}else{
						x = 0;
					}
					break;
				default:
					x = 0;
			}
			_measureFlag.validate();
			_popoutDisplay.popoutLayoutInfo.minWidth = minListWidth;
			_popoutDisplay.popoutLayoutInfo.relativeOffsetX = x;
			_popoutDisplay.popoutLayoutInfo.relativeOffsetY = y;
			_popoutDisplay.popoutLayout.update();
		}
		protected function getListAlignArea():Rectangle{
			return null;
		}
		protected function getListAlignMeas():Rectangle{
			return null;
		}
		protected function onListMeasureChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		protected function closeOnClickOutside():Boolean{
			return false;
		}
	}
}