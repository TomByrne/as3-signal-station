package org.farmcode.actLibrary.display.visualSockets.socketContainers
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.display.visualSockets.plugs.PlugDisplay;
	import org.farmcode.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.core.IOutroView;
	import org.farmcode.display.layout.ILayout;
	import org.farmcode.display.layout.ILayoutSubject;
	
	public class SocketContainer extends PlugDisplay implements ISocketContainer
	{
		override public function set displaySocket(value:IDisplaySocket):void{
			super.displaySocket = value;
			checkHelper();
		}
		override public function set asset(value:IDisplayAsset):void{
			super.asset = value;
			checkHelper();
		}
		
		public function get layout():ILayout{
			return _layout;
		}
		public function set layout(value:ILayout):void{
			if(_layout!=value){
				var socket:IDisplaySocket;
				var layoutSocket:ILayoutSubject;
				if(_layout){
					for each(socket in socketContHelper.childSockets){
						layoutSocket = (socket as ILayoutSubject);
						if(layoutSocket)_layout.removeSubject(layoutSocket);
					}
					_layout.scopeView = null;
				}
				_layout = value;
				if(_layout){
					_layout.scopeView = this;
					for each(socket in socketContHelper.childSockets){
						layoutSocket = (socket as ILayoutSubject);
						if(layoutSocket)_layout.addSubject(layoutSocket);
					}
					invalidate();
				}
			}
		}
		override public function get display():IDisplayAsset{
			var ret:IDisplayAsset = super.display;
			if(!ret){
				// TODO: fix this
				//ret = asset = new Sprite();
				throw new Error();
			}
			return ret;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get childSocketsChanged():IAct{
			return _childSocketsChanged;
		}
		
		protected var _childSocketsChanged:Act = new Act();
		private var _layout:ILayout;
		protected var _socketContHelper:SocketContainerHelper;
		protected var _childContainer:IContainerAsset;
		
		public function SocketContainer(asset:IDisplayAsset=null){
			super(asset);
		}
		override public function setDataProvider(value:*, execution:UniversalActExecution=null):void{
			super.setDataProvider(value,execution);
			socketContHelper.setDataProvider(value,execution);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_childContainer = _asset.factory.createContainer();
			_containerAsset.addAsset(_childContainer);
		}
		override protected function unbindFromAsset() : void{
			_containerAsset.removeAsset(_childContainer);
			_asset.factory.destroyAsset(_childContainer);
			super.unbindFromAsset();
		}
		public function get childSockets(): Array{
			return socketContHelper.childSockets;
		}
		public function set childSockets(value: Array):void{
			if(_layout){
				var old:Array = socketContHelper.childSockets;
				var socket:IDisplaySocket;
				var layoutSocket:ILayoutSubject;
				for (var i:int=0; i<old.length; i++){
					socket = old[i];
					if(!value || value.indexOf(socket)==-1){
						layoutSocket = (socket as ILayoutSubject);
						if(layoutSocket)_layout.removeSubject(layoutSocket);
						else i++;
					}else{
						i++;
					}
				}
				if(value){
					for each(socket in value){
						if(old.indexOf(socket)==-1){
							layoutSocket = (socket as ILayoutSubject);
							if(layoutSocket)_layout.addSubject(layoutSocket);
						}
					}
				}
			}
			socketContHelper.childSockets = value;
		}
		public function get dataPropertyBindings(): Dictionary{
			return socketContHelper.dataPropertyBindings;
		}
		public function set dataPropertyBindings(value: Dictionary):void{
			socketContHelper.dataPropertyBindings = value;
		}
		protected function get socketContHelper(): SocketContainerHelper{
			if(!_socketContHelper){
				_socketContHelper = new SocketContainerHelper(this,_childSocketsChanged);
				_socketContHelper.defaultContainer = _childContainer;
				_socketContHelper.childDataAssessed.addHandler(onChildDataAssessed);
			}
			return _socketContHelper;
		}
		protected function onChildDataAssessed(from:SocketContainerHelper):void{
			// this is so that when child sockets are filled they have the correct position.
			_layout.validate();
		}
		override protected function doShowIntro():void{
			checkHelper();
			super.doShowIntro();
		}
		override protected function doShowOutro():Number{
			checkHelper();
			var ret:Number = super.doShowOutro();
			for each(var socket:IDisplaySocket in childSockets){
				if(socket.plugDisplay){
					var cast:IOutroView = (socket.plugDisplay as IOutroView);
					ret = Math.max(ret,cast.showOutro());
				}
			}
			return ret;
		}
		protected function checkHelper():void{
			if(!_outroShown && displaySocket){
				socketContHelper.asset = asset;
			}else{
				socketContHelper.asset = null;
			}
		}
		override protected function draw():void{
			super.draw();
			drawLayout();
			if(_containerAsset){
				if(_containerAsset.scaleX!=0 && _containerAsset.scaleX!=Infinity){
					_containerAsset.scaleX = 1/_containerAsset.scaleX;
				}
				if(_containerAsset.scaleY!=0 && _containerAsset.scaleY!=Infinity){
					_containerAsset.scaleY = 1/_containerAsset.scaleY;
				}
			}
		}
		protected function drawLayout():void{
			if(_layout){
				_layout.setLayoutSize(displayPosition.x-_containerAsset.x,displayPosition.y-_containerAsset.y,displayPosition.width,displayPosition.height);
			}
		}
	}
}