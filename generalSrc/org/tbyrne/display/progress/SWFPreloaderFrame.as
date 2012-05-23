package org.tbyrne.display.progress
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	import org.tbyrne.core.IApplication;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.core.NumberData;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.debug.DebugManager;
	import org.tbyrne.display.assets.nativeAssets.DisplayObjectContainerAsset;
	import org.tbyrne.display.assets.nativeAssets.NativeAssetFactory;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.IOutroView;
	
	public class SWFPreloaderFrame extends Sprite
	{
		private static const CLASS_FILENAME_PATTERN:RegExp = /^.*\/(.*)\..*$/;
		private static const TEST_TIME:Number = 5;
		
		public function get progressDisplay():IProgressDisplay{
			return _progressDisplay;
		}
		public function set progressDisplay(value:IProgressDisplay):void{
			if(_progressDisplay!=value){
				if(_progressDisplay){
					clearProgressDisplay();
				}
				_progressDisplay = value;
				if(_progressDisplay){
					commitProgressDisplay();
				}
			}
		}
		
		
		
		public function get layoutView():ILayoutView{
			return _layoutView;
		}
		public function set layoutView(value:ILayoutView):void{
			if(_layoutView!=value){
				if(_layoutView){
					_nativeAsset.removeAsset(_layoutView.asset);
				}
				_layoutView = value;
				if(_progressDisplay){
					if(_layoutView){
						_layoutView.setPosition(0,0);
						applySizeToProgressDisplay();
						_nativeAsset.addAsset(_layoutView.asset);
					}
					_progressDisplayAnim = (_layoutView as IOutroView);
				}
			}
		}
		
		protected function get nativeFactory():NativeAssetFactory{
			if(!_nativeFactory)_nativeFactory = new NativeAssetFactory();
			return _nativeFactory;
		}
		public var mainClasspath:String;
		
		private var _layoutView:ILayoutView;
		protected var _progressDisplay:IProgressDisplay;
		private var _progressDisplayAnim:IOutroView;
		private var _totalFound:Boolean = false;
		private var _measureFactor:Number;
		private var _application:IApplication;
		private var _nativeFactory:NativeAssetFactory;
		private var _nativeAsset:DisplayObjectContainerAsset;
		
		private var _messageData:StringData;
		private var _unitsData:StringData;
		private var _measurableData:BooleanData;
		private var _totalData:NumberData;
		private var _progressData:NumberData;
		
		public function SWFPreloaderFrame(mainClasspath: String=null, progressDisplay:IProgressDisplay=null, layoutView:ILayoutView=null, runTest:Boolean=false){
			super();
			_nativeAsset = nativeFactory.getNew(this);
			
			_messageData = new StringData();
			_unitsData = new StringData();
			_measurableData = new BooleanData();
			_totalData = new NumberData();
			_progressData = new NumberData();
			
			this.mainClasspath = mainClasspath;
			this.progressDisplay = progressDisplay;
			this.layoutView = layoutView;
			init(runTest);
		}
		protected function init(runTest:Boolean): void{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			if(runTest){
				_messageData.stringValue = "Testing";
				_unitsData.stringValue = "s";
				_measurableData.booleanValue = true;
				_totalData.numericalValue = TEST_TIME;
				addEventListener(Event.ENTER_FRAME, doTest);
			}else if(root.loaderInfo.bytesTotal > 0 && root.loaderInfo.bytesLoaded >= root.loaderInfo.bytesTotal){
				_totalData.numericalValue = root.loaderInfo.bytesTotal;
				loadCompleted();
			}else{
				_messageData.stringValue = "Loading";
				_measurableData.booleanValue = false;
				root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				root.loaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
				root.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				onLoadProgress();
			}
		}
		private function doTest(event: Event): void{
			var progress:Number = getTimer()/1000;
			if(progress<TEST_TIME){
				_progressData.numericalValue = progress;
			}else{
				removeEventListener(Event.ENTER_FRAME, doTest);
				loadCompleted();
			}
		}
		private function onLoadProgress(event: Event=null): void{
			if(!_totalFound && root.loaderInfo.bytesTotal>0){
				_measurableData.booleanValue = true;
				var total:Number = root.loaderInfo.bytesTotal;
				if(total<1024){
					_unitsData.stringValue = "b";
					_measureFactor = 1;
				}else{
					total /= 1024;
					if(total<1024){
						_unitsData.stringValue = "kb";
						_measureFactor = 1024;
					}else{
						total /= 1024;
						_unitsData.stringValue = "mb";
						_measureFactor = 1024*1024;
					}
				}
				_totalData.numericalValue = total;
				_totalFound = true;
			}
			if(_totalFound){
				_progressData.numericalValue = root.loaderInfo.bytesLoaded/_measureFactor;
			}
		}
		private function onLoadComplete(event: Event): void{
			root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			root.loaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			root.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loadCompleted();
		}
		private function onLoadError(event: Event): void{
			_messageData.stringValue = "Error";
			_measurableData.booleanValue = false;
		}
		private function onStageResize(event: Event): void{
			if(_layoutView)applySizeToProgressDisplay();
			if(_application)applySizeToApplication();
		}
		private function applySizeToProgressDisplay(): void{
			_layoutView.setSize(stage.stageWidth,stage.stageHeight);
		}
		private function applySizeToApplication(): void{
			_application.setSize(stage.stageWidth,stage.stageHeight);
		}
		protected function loadCompleted():void{
			_progressData.numericalValue = _totalData.numericalValue;
			addEventListener(Event.ENTER_FRAME, instantiateApp);
		}
		protected function instantiateApp(e:Event):void{
			
			var className:String = (mainClasspath?mainClasspath:guessClassName());
			try{
				var mainClass:Class = getDefinitionByName(className) as Class;
			}catch(e:ReferenceError){
				// for whatever reason, sometimes it takes a few frames to get the classes set up.
				return;
			}
			removeEventListener(Event.ENTER_FRAME, instantiateApp);
			
			_application = new mainClass();
			
			CONFIG::debug{
				_application = DebugManager.addApplication(_application);
			}
			_application.setPosition(0,0);
			applySizeToApplication();
			
			if(_progressDisplayAnim){
				var timer:Timer = new Timer(_progressDisplayAnim.showOutro()*1000,1);
				timer.addEventListener(TimerEvent.TIMER, onOutroFinished);
				timer.start();
			}else{
				addAppToStage();
			}
		}
		protected function onOutroFinished(e:Event):void{
			var timer:Timer = (e.target as Timer);
			timer.removeEventListener(TimerEvent.TIMER, onOutroFinished);
			addAppToStage();
		}
		protected function addAppToStage():void{
			_nativeAsset.removeAsset(_layoutView.asset);
			_application.container = _nativeAsset;
		}
		private function guessClassName():String{
			var results:Object = CLASS_FILENAME_PATTERN.exec(unescape(stage.loaderInfo.url));
			return results[1];
		}
		
		
		protected function clearProgressDisplay():void{
			_progressDisplay.active = null;
			_progressDisplay.measurable = null;
			_progressDisplay.total = null;
			_progressDisplay.progress = null;
			_progressDisplay.units = null;
			_progressDisplay.message = null;
		}
		
		protected function commitProgressDisplay():void{
			_progressDisplay.active = new BooleanData(true);
			_progressDisplay.measurable = _measurableData;
			_progressDisplay.total = _totalData;
			_progressDisplay.progress = _progressData;
			_progressDisplay.units = _unitsData;
			_progressDisplay.message = _messageData;
		}
		
		protected function onUncaughtError(event:UncaughtErrorEvent):void{
			Log.log(Log.DEV_ERROR,"Unhandled exception: "+event.error);
		}
	}
}