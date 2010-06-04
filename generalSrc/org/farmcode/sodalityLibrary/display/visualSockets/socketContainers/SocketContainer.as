package org.farmcode.sodalityLibrary.display.visualSockets.socketContainers
{
	import au.com.thefarmdigital.delayedDraw.IDrawable;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import org.farmcode.display.ISelfAnimatingView;
	import org.farmcode.display.layout.ILayout;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.PlugDisplay;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;
	
	public class SocketContainer extends PlugDisplay implements ISocketContainer
	{
		override public function set displaySocket(value:IDisplaySocket):void{
			super.displaySocket = value;
			checkHelper();
		}
		override public function set asset(value:DisplayObject):void{
			if(containerAsset){
				containerAsset.removeChild(childContainer);
			}
			super.asset = value;
			_advisor.advisorDisplay = value;
			checkHelper();
			if(containerAsset){
				containerAsset.addChild(childContainer);
			}
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
				}
				_layout = value;
				_layoutView = (_layout as IDrawable);
				if(_layout){
					for each(socket in socketContHelper.childSockets){
						layoutSocket = (socket as ILayoutSubject);
						if(layoutSocket)_layout.addSubject(layoutSocket);
					}
					invalidate();
				}
			}
		}
		override public function get display():DisplayObject{
			var ret:DisplayObject = super.display;
			if(!ret){
				ret = asset = new Sprite();
			}
			return ret;
		}
		
		private var _layout:ILayout;
		private var _layoutView:IDrawable;
		protected var _socketContHelper:SocketContainerHelper;
		protected var _advisor:DynamicAdvisor = new DynamicAdvisor();
		protected var childContainer:Sprite = new Sprite();
		
		public function SocketContainer(asset:DisplayObject=null){
			super(asset);
		}
		override public function setDataProvider(value:*, cause:IAdvice=null):void{
			super.setDataProvider(value,cause);
			socketContHelper.setDataProvider(value,cause);
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
				_socketContHelper = new SocketContainerHelper(this,_advisor);
				_socketContHelper.defaultContainer = childContainer;
				_socketContHelper.childDataAssessed.addHandler(onChildDataAssessed);
			}
			return _socketContHelper;
		}
		protected function onChildDataAssessed(from:SocketContainerHelper):void{
			// this is so that when child sockets are filled they have the correct position.
			if(_layoutView){
				_layoutView.validate();
			}
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
					var cast:ISelfAnimatingView = (socket.plugDisplay as ISelfAnimatingView);
					ret = Math.max(ret,cast.showOutro());
				}
			}
			return ret;
		}
		protected function checkHelper():void{
			if(!_outroShown && displaySocket){
				socketContHelper.display = asset;
			}else{
				socketContHelper.display = null;
			}
		}
		override protected function draw():void{
			super.draw();
			drawLayout();
			if(containerAsset){
				if(containerAsset.scaleX!=0 && containerAsset.scaleX!=Infinity){
					childContainer.scaleX = 1/containerAsset.scaleX;
				}
				if(containerAsset.scaleY!=0 && containerAsset.scaleY!=Infinity){
					childContainer.scaleY = 1/containerAsset.scaleY;
				}
			}
		}
		protected function drawLayout():void{
			if(_layout){
				_layout.setLayoutSize(displayPosition.x-containerAsset.x,displayPosition.y-containerAsset.y,displayPosition.width,displayPosition.height);
			}
		}
	}
}