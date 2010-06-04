package au.com.thefarmdigital.display
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	import org.farmcode.core.DelayedCall;
	import org.farmcode.memory.ObjectLocker;
	
	/**
	 *	Add the following metadata above the class definition of your main application class:
	 * 
	 *	[Frame(factoryClass="au.com.package.to.MyPreloaderView")]
	 */
	public class AbstractPreloaderView extends Sprite
	{
		private static const CLASS_FILENAME_PATTERN:RegExp = /^.*\/(.*)\..*$/;
		private static const TEST_TIME:Number = 15;
		
		private var mainClassName: String;
		private var inited: Boolean;
		protected var allowNonDisplayMainClass: Boolean;
		protected var classDetectionAttempts: uint;
		protected var maxClassDetectionAttempts: uint;
		
		public function AbstractPreloaderView(mainClassName: String=null, 
			allowNonDisplayMainClass: Boolean = false, runTest:Boolean = false)
		{
			super();
			
			this.inited = false;
			
			this.maxClassDetectionAttempts = 10;
			this.classDetectionAttempts = 0;
			
			this.allowNonDisplayMainClass = allowNonDisplayMainClass;
			this.mainClassName = mainClassName;
			
			this.configureStage();
			this.createUI();
			
			if(runTest){
				this.addEventListener(Event.ENTER_FRAME, doTest);
				this.stage.addEventListener(Event.RESIZE, this.handleStageResizeEvent);
			}else if (this.root.loaderInfo.bytesTotal > 0 && 
				this.root.loaderInfo.bytesLoaded >= this.root.loaderInfo.bytesTotal){
				this.loadCompleted();
			}else{
				this.root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, this.handleLoadProgressEvent);
				this.root.loaderInfo.addEventListener(Event.COMPLETE, this.handleLoadCompleteEvent);
				this.root.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.handleLoadErrorEvent);
				this.stage.addEventListener(Event.RESIZE, this.handleStageResizeEvent);
				
				// Delay it one frame in order to give subclass time to create ui in constructor
				var delayedCall:DelayedCall = new DelayedCall(tryUpdateUIPosition,1,false);
				delayedCall.begin();
			}
			tryUpdateUIPosition();
		}
		
		protected function createUI(): void{
			
		}
		
		protected function configureStage(): void
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
        private function doTest(event: Event): void
        {
        	displayPercent(getTimer()/(TEST_TIME*1000));
        }
        private function handleStageResizeEvent(event: Event): void
        {
        	this.tryUpdateUIPosition();
        }
        
        private function handleLoadProgressEvent(event: ProgressEvent):void
        {
        	var percent: Number = this.root.loaderInfo.bytesLoaded / this.root.loaderInfo.bytesTotal;	
        	this.displayPercent(percent);
        }
        
        private function tryUpdateUIPosition(): void
        {
        	if (this.stage != null)
        	{
        		this.updateUIPosition();
        	}
        }
        
        protected function updateUIPosition(): void
        {
        	
        }
        
        protected function displayPercent(percent: Number): void
        {
        	
        }
        
        private function handleLoadErrorEvent(event: Event): void
        {
        	trace("WARNING: Error loading in swf file");
        }
        
        private function handleLoadCompleteEvent(event: Event):void
        {
        	this.loadCompleted();
        }   
        
        protected function loadCompleted():void
        {
        	this.disposeChecking();
        	
        	this.displayPercent(1);
        	
        	// Wait one frame for initialisation because the mainClassName isn't loaded in memory
        	var delayedCall:DelayedCall = new DelayedCall(init, 1, false);
        	delayedCall.begin();
        }
        
        private function tryLoadMainClass(): Class
        {
        	var mainClass: Class = null;
			var className:String = (mainClassName?mainClassName:guessClassName());
			mainClass = getDefinitionByName(className) as Class;
    		return mainClass;
        }
        private function guessClassName():String{
        	var loaderInfo:LoaderInfo = stage.loaderInfo;
        	var results:Object = CLASS_FILENAME_PATTERN.exec(unescape(loaderInfo.url));
        	return results[1];
        }
        protected function init(): void
        {
        	if (!this.inited)
        	{
        		var mainClass: Class = this.tryLoadMainClass();
        		
        		if (mainClass)
        		{
        			this.inited = true;
        			
        			var app: Object = new mainClass();
	                if (app is DisplayObject)
	                {
	                	var displayApp: DisplayObject = app as DisplayObject;
	                	addMainView(displayApp);
	                	
	                	this.applicationCreated();
	                }
	                else if (this.allowNonDisplayMainClass)
	                {
	                	// Is a non display application
	                	ObjectLocker.lock(app);
	                }
	                else
	                {
	                	throw new ReferenceError("Main Class " + this.mainClassName + " must inherit from DisplayObject");
	                }
        		}
        		else if (this.classDetectionAttempts < this.maxClassDetectionAttempts)
        		{
        			var delayedCall:DelayedCall = new DelayedCall(init, 1, false);
        			delayedCall.begin();
        			this.classDetectionAttempts++;
        		}
        		else
        		{
        			throw new ReferenceError("Main Class " + this.mainClassName + " couldn't be found in the application");
        		}
	        }
        }
        
        protected function addMainView(displayApp:DisplayObject): void{
	        stage.addChild(displayApp);
        }
        protected function disposeChecking(): void
        {
        	this.stage.removeEventListener(Event.RESIZE, this.handleStageResizeEvent);            
			this.root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, this.handleLoadProgressEvent);
			this.root.loaderInfo.removeEventListener(Event.COMPLETE, this.handleLoadCompleteEvent);
			this.root.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.handleLoadErrorEvent);
        }
        
        protected function applicationCreated(): void
        {
        	
        }				            
	}
}