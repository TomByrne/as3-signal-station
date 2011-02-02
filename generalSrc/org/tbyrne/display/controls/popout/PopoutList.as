package org.tbyrne.display.controls.popout {
	import flash.geom.Point;
	
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.utils.isDescendant;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.containers.ListBox;
	import org.tbyrne.display.controls.Control;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.instanceFactory.IInstanceFactory;
	
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
				invalidateSize();
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
		
		public function PopoutList(asset:IDisplayObject=null) {
			super(asset);
			
			_popoutDisplay=new PopoutDisplay();
			_popoutDisplay.relativeTo = this;
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
		protected function onMouseDown(from:IInteractiveObject, info:IMouseActInfo):void {
			if(info.mouseTarget!=asset && !isDescendant(_containerAsset,info.mouseTarget) &&
				info.mouseTarget!=_listBox.asset && !isDescendant(_listBox.asset as IDisplayObjectContainer,info.mouseTarget)){
				_popoutDisplay.popoutShown = false;
			}
		}
		override protected function bindToAsset():void {
			var listAsset:IDisplayObject = _containerAsset.takeAssetByName(LIST_CHILD,IDisplayObject);
			_containerAsset.removeAsset(listAsset);
			_listBox.asset=listAsset;
			super.bindToAsset();
		}
		
		override protected function unbindFromAsset():void {
			super.unbindFromAsset();
			var listAsset:IAsset = _listBox.asset;
			_containerAsset.addAsset(_listBox.asset);
			_listBox.asset=null;
		}
		
		override protected function measure():void {
			super.measure();
			addListToMeas();
		}
		protected function addListToMeas():void {
			var listMeas:Point = _listBox.measurements;
			switch(_listAnchor){
				case Anchor.TOP:
				case Anchor.CENTER:
				case Anchor.BOTTOM:
					if(_measurements.x<listMeas.x){
						_measurements.x = listMeas.x;
					}
					break;
			}
		}
		override protected function commitSize():void{
		}
		protected function onListMeasureChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			switch(_listAnchor){
				case Anchor.TOP:
				case Anchor.CENTER:
				case Anchor.BOTTOM:
					invalidateMeasurements();
					break;
			}
		}
		protected function closeOnClickOutside():Boolean{
			return false;
		}
	}
}