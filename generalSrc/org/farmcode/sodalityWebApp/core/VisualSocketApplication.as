package org.farmcode.sodalityWebApp.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advice.MethodAdvice;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.core.ConfiguredApplication;
	import org.farmcode.sodalityLibrary.core.StateApplication;
	import org.farmcode.sodalityLibrary.display.visualSockets.VisualSocketAdvisor;
	import org.farmcode.sodalityLibrary.display.visualSockets.VisualSocketNamespace;
	import org.farmcode.sodalityLibrary.display.visualSockets.debug.VisualSocketOutliner;
	import org.farmcode.sodalityLibrary.display.visualSockets.events.DisplaySocketEvent;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.DisplaySocket;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.sodalityLibrary.external.browser.BrowserAdvisor;
	import org.farmcode.sodalityLibrary.external.swfaddress.advice.SetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.ISetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.utils.config.advice.GetConfigParamAdvice;
	import org.farmcode.sodalityWebApp.appState.AppStateAdvisor;
	
	use namespace VisualSocketNamespace;
	
	/*[SWF(width=1000, height=750, frameRate=30, backgroundColor="#ffffff")]
	[Frame(factoryClass="org.farmcode.display.progress.SimpleSWFPreloaderFrame")] */ // this must be on subclass
	public class VisualSocketApplication extends StateApplication implements IDisplaySocket
	{
		
		override public function set container(value:DisplayObjectContainer) : void{
			super.container = value;
			_proxiedDisplaySocket.container = value;
		}
		public function get socketId(): String{
			return _proxiedDisplaySocket.socketId;
		}
		public function get plugMappers(): Array{
			return _proxiedDisplaySocket.plugMappers;
		}
		public function get globalPosition(): Rectangle{
			return _proxiedDisplaySocket.globalPosition;
		}
		public function get plugDisplay():IPlugDisplay{
			return _proxiedDisplaySocket.plugDisplay;
		}
		public function set plugDisplay(value:IPlugDisplay):void{
			_proxiedDisplaySocket.plugDisplay = value;
		}
		public function set socketPath(value:String):void{
			_proxiedDisplaySocket.socketPath = value;
		}
		public function get socketPath():String{
			return _proxiedDisplaySocket.socketPath;
		}
		override public function get measurementsChanged() : IAct{
			return _proxiedDisplaySocket.measurementsChanged;
		}
		override public function get displayMeasurements() : Rectangle{
			return _proxiedDisplaySocket.displayMeasurements;
		}
		
		protected var _visSocketAdvisor:VisualSocketAdvisor;
		protected var _config:IVisualSocketAppConfig;
		protected var _proxiedDisplaySocket:DisplaySocket;
		
		public function VisualSocketApplication(asset:DisplayObject=null){
			super(asset);
			_proxiedDisplaySocket = new DisplaySocket("");
			_proxiedDisplaySocket.displayDepth = 0;// forces app to lowest level, allowing debug bar to sit at top.
			_proxiedDisplaySocket.addEventListener(DisplaySocketEvent.PLUG_DISPLAY_CHANGED, onPlugDisplayChanged);
		}
		protected function onPlugDisplayChanged(event:DisplaySocketEvent):void{
			dispatchEvent(event);
		}
		override public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number) : void{
			super.setDisplayPosition(x, y, width, height);
			_proxiedDisplaySocket.setDisplayPosition(x, y, width, height);
		}
		override protected function init():void{
			super.init();
			
			_visSocketAdvisor = new VisualSocketAdvisor();
			_visSocketAdvisor.rootSocket = this;
			_visSocketAdvisor.advisorDisplay = container;
			
			var browserAdvisor:BrowserAdvisor = new BrowserAdvisor();
			browserAdvisor.advisorDisplay = container;
			
			Config::DEBUG
			{
				var onKeyDown:Function = function(e:KeyboardEvent):void{
					if(e.ctrlKey && e.altKey){
						if(e.keyCode==79)VisualSocketOutliner.outlineSocket(_debugArea.graphics,_visSocketAdvisor.rootSocketBundle);		// o
					}
				}
				_lastStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
		}
		override protected function setRootObject(object:Object):IAdvice{
			_config = object as IVisualSocketAppConfig;
			_visSocketAdvisor.rootDataMappers = _config.rootDataMappers;
			return super.setRootObject(object);
		}
	}
}