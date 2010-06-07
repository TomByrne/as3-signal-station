package org.farmcode.sodalityLibrary.display.visualSockets.plugs.containers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.containers.ScrollWrapper;
	import org.farmcode.display.containers.accordion.AccordionRenderer;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.grid.IGridLayoutSubject;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityLibrary.display.visualSockets.advice.FillSocketAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.socketContainers.ISocketContainer;
	import org.farmcode.sodalityLibrary.display.visualSockets.socketContainers.SocketContainerHelper;
	import org.farmcode.sodalityLibrary.display.visualSockets.socketContainers.SocketContainerUtils;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.DisplaySocket;
	
	public class AccordionPlugRenderer extends AccordionRenderer implements ISocketContainer, IGridLayoutSubject
	{
		override public function set asset(value:IDisplayAsset) : void{
			super.asset = value;
			_dynamicAdvisor.advisorDisplay = value?value.drawDisplay:null;
			_socketContainerHelper.display = value;
			attemptFillSocket();
		}
		override public function set data(value:IBooleanProvider) : void{
			if(super.data != value){
				super.data = value;
				_dataChanged = true;
				attemptFillSocket();
			}
		}
		public function get childSockets():Array{
			return _socketContainerHelper.childSockets;
		}
		
		public function get dataProperty():String{
			return _dataProperty;
		}
		public function set dataProperty(value:String):void{
			if(_dataProperty!=value){
				_dataProperty = value;
				_dataChanged = true;
				attemptFillSocket();
			}
		}
		public function get columnIndex():int{
			return _columnIndex;
		}
		public function set columnIndex(value:int):void{
			if(_columnIndex!=value){
				_columnIndex = value;
				if(_rowIndex!=-1 && _columnIndex!=-1){
					_displaySocket.socketId = String(_rowIndex+_columnIndex);
				}else{
					_displaySocket.socketId = null;
				}
				attemptFillSocket();
			}
		}
		
		public function get rowIndex():int{
			return _rowIndex;
		}
		public function set rowIndex(value:int):void{
			if(_rowIndex!=value){
				_rowIndex = value;
				if(_rowIndex!=-1 && _columnIndex!=-1){
					_displaySocket.socketId = String(_rowIndex+_columnIndex);
				}else{
					_displaySocket.socketId = null;
				}
				attemptFillSocket();
			}
		}
		
		private var _rowIndex:int = -1;
		private var _columnIndex:int = -1;
		
		private var _dataProperty:String;
		protected var _accordionIndex:int;
		protected var _displaySocket:DisplaySocket = new DisplaySocket();
		protected var _socketFilled:Boolean;
		protected var _dataChanged:Boolean;
		protected var _dynamicAdvisor:DynamicAdvisor = new DynamicAdvisor();
		protected var _socketContainerHelper:SocketContainerHelper;
		protected var _scrollRect:Rectangle = new Rectangle();
		protected var _scrollWrapper:ScrollWrapper;
		
		public function AccordionPlugRenderer(asset:IDisplayAsset=null){
			_displaySocket.measurementsChanged.addHandler(onSocketMeasChange);
			_scrollWrapper = new ScrollWrapper(_displaySocket);
			_dynamicAdvisor.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdvisorAdded);
			_socketContainerHelper = new SocketContainerHelper(this,_dynamicAdvisor);
			_socketContainerHelper.childSockets = [_displaySocket];
			super(asset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_displaySocket.container = _asset.createAsset("container",IContainerAsset);
			_containerAsset.addAsset(_displaySocket.container);
			if(_scrollBar){
				_scrollBar.scrollSubject = _scrollWrapper;
				if(_scrollBar.direction==Direction.HORIZONTAL){
					_scrollWrapper.allowVerticalScroll = false;
					_scrollWrapper.allowHorizontalScroll = true;
				}else{
					_scrollWrapper.allowVerticalScroll = true;
					_scrollWrapper.allowHorizontalScroll = false;
				}
			}
		}
		override protected function unbindFromAsset() : void{
			_containerAsset.removeAsset(_displaySocket.container);
			_asset.destroyAsset(_displaySocket.container);
			_displaySocket.container = null;
			super.unbindFromAsset();
		}
		override protected function getContainerMeasurements() : Rectangle{
			return _displaySocket.displayMeasurements;
		}
		override protected function setContainerSize(x:Number, y:Number, width:Number, height:Number) : void{
			_scrollWrapper.setDisplayPosition(x,y,width,height);
		}
		protected function onSocketMeasChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
			invalidate();
		}
		protected function onAdvisorAdded(e:Event):void{
			attemptFillSocket();
		}
		override protected function draw() : void{
			super.draw();
			_scrollRect.width = displayPosition.width;
			_scrollRect.height = displayPosition.height;
			_containerAsset.scrollRect = _scrollRect;
		}
		override public function commitProviderState():void{
			attemptFillSocket();
			super.commitProviderState();
		}
		public function attemptFillSocket():void{
			if(_dynamicAdvisor.addedToPresident && _displaySocket.socketId!=null && openFract){
				var childData:* = SocketContainerUtils.getProperty(data,_dataProperty);
				var fillAdvice:FillSocketAdvice;
				var doFill:Boolean;
				if(_socketFilled && childData==null){
					_socketFilled = false;
					doFill = true;
				}else if((!_socketFilled || _dataChanged || _displaySocket.plugDisplay==null) && childData!=null){
					_socketFilled = true;
					doFill = true;
				}
				if(doFill){
					fillAdvice = new FillSocketAdvice(null,childData);
					fillAdvice.displaySocket = _displaySocket;
					_dynamicAdvisor.dispatchEvent(fillAdvice);
				}
				_dataChanged = false;
			}
		}
	}
}