package org.farmcode.display.behaviour.controls.popoutList {
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.behaviour.containers.ListBox;
	import org.farmcode.display.behaviour.controls.Control;
	import org.farmcode.display.behaviour.misc.PopoutDisplay;
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	/**
	 * The PopoutList class forms the base functionality for both DropDownLists
	 * and ComboBoxes. It is comprised of a togglable button which, when selected,
	 * displays a list of options.
	 */
	public class PopoutList extends Control {
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
		
		public function PopoutList(asset:DisplayObject=null) {
			super(asset);
			_popoutDisplay=new PopoutDisplay();
			_popoutDisplay.popoutOpen.addHandler(onPopoutOpen);
			_popoutDisplay.popoutClose.addHandler(onPopoutClose);
			_listBox=new ListBox();
			_listBox.measurementsChanged.addHandler(onListMeasureChange);
			_popoutDisplay.popout = _listBox;
			_displayMeasurements = new Rectangle();
		}
		protected function onPopoutOpen(popoutDisplay:PopoutDisplay, popout:ListBox):void {
			if(closeOnClickOutside()){
				asset.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		protected function onPopoutClose(popoutDisplay:PopoutDisplay, popout:ListBox):void {
			if(closeOnClickOutside()){
				asset.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		protected function onMouseDown(e:MouseEvent):void {
			var mouseTarget:DisplayObject = (e.target as DisplayObject);
			if(mouseTarget!=asset && !DisplayUtils.isDescendant(containerAsset,mouseTarget) &&
				mouseTarget!=_listBox.containerAsset && !DisplayUtils.isDescendant(_listBox.containerAsset,mouseTarget)){
				_popoutDisplay.popoutShown = false;
			}
		}
		override protected function bindToAsset():void {
			_popoutDisplay.asset=asset;
			var listAsset:DisplayObject = containerAsset.getChildByName("list");
			containerAsset.removeChild(listAsset);
			_listBox.asset=listAsset;
		}
		
		override protected function unbindFromAsset():void {
			_popoutDisplay.asset=null;
			var listAsset:DisplayObject = _listBox.asset;
			containerAsset.addChild(_listBox.asset);
			_listBox.asset=null;
		}
		
		override protected function measure():void {
			var alignArea:Rectangle = getListAlignMeas();
			var listMeas:Rectangle = _listBox.displayMeasurements;
			_displayMeasurements.x = alignArea.x;
			_displayMeasurements.y = alignArea.y;
			switch(_listAnchor){
				case Anchor.TOP:
				case Anchor.CENTER:
				case Anchor.BOTTOM:
					if(alignArea.width>listMeas.width){
						_displayMeasurements.width = alignArea.width;
					}else{
						_displayMeasurements.width = listMeas.width;
					}
					break;
				default:
					_displayMeasurements.width = alignArea.width+listMeas.width
					break;
			}
			_displayMeasurements.height = alignArea.height;
		}
		override protected function draw():void {
			var listMeas:Rectangle = _listBox.displayMeasurements;
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
						y = alignArea.top-listMeas.bottom;
						minListWidth = alignArea.width;
					}else{
						y = -listMeas.bottom;
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
						y = (alignArea.y+alignArea.height/2)-(listMeas.y+listMeas.height/2);
					}else{
						y = 0;
					}
			}
			switch(_listAnchor){
				case Anchor.LEFT:
				case Anchor.TOP_LEFT:
				case Anchor.BOTTOM_LEFT:
					if(useRect){
						x = alignArea.left-listMeas.right;
					}else{
						x = -listMeas.left;
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
			_popoutDisplay.popoutLayoutInfo.minWidth = minListWidth;
			_popoutDisplay.popoutLayoutInfo.relativeOffsetX = x;
			_popoutDisplay.popoutLayoutInfo.relativeOffsetY = y;
			_popoutDisplay.popoutLayout.invalidate();
		}
		protected function getListAlignArea():Rectangle{
			return null;
		}
		protected function getListAlignMeas():Rectangle{
			return null;
		}
		protected function onListMeasureChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		protected function closeOnClickOutside():Boolean{
			return false;
		}
	}
}