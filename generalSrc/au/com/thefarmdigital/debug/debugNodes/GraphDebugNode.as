package au.com.thefarmdigital.debug.debugNodes
{
	import au.com.thefarmdigital.debug.infoSources.INumericInfoSource;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class GraphDebugNode extends AbstractVisualDebugNode
	{
		public function set recordDelay(value:Number):void{
			if(_recordDelay!=value){
				_recordDelay = value;
				_timer.reset();
				_timer.delay = value*1000;
				if(_timer.delay){
					_timer.start();
				}
				clearAllRecordings();
			}
		}
		public function get recordDelay():Number{
			return _recordDelay;
		}
		
		private var graphBitmap:Bitmap;
		private var _recordDelay:Number;
		private var _timer:Timer = new Timer(0,0);
		private var _infoBundles:Array = [];
		
		
		public function GraphDebugNode(recordDelay:Number=0.2, width:Number=130, height:Number=100){
			super();
			
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			this.width = width;
			this.height = height;
			this.recordDelay = recordDelay;
		}
		public function addInfoSource(infoSource:INumericInfoSource, upperLimit:Number=NaN, lowerLimit:Number=NaN) : void{
			_infoBundles.push(new InfoSourceBundle(infoSource, upperLimit, lowerLimit));
		}
		public function removeInfoSource(infoSource:INumericInfoSource) : void{
			for(var i:int=0; i<_infoBundles.length; i++){
				var infoBundle:InfoSourceBundle = _infoBundles[i];
				if(infoBundle.infoSource==infoSource){
					_infoBundles.splice(i,1);
					drawAllRecordings(true);
					return;
				}
			}
		}
		protected function onTimer(e:TimerEvent) : void{
			var redrawAll:Boolean = false;
			for each(var infoBundle:InfoSourceBundle in _infoBundles){
				var value:Number = infoBundle.infoSource.numericOutput;
				infoBundle.recordings.unshift(value);
				if(infoBundle.recordings.length>width){
					infoBundle.recordings.pop();
				}
				if(value>infoBundle.maxRecorded){
					redrawAll = true;
					infoBundle.maxRecorded = value;
				}
			}
			if(graphBitmap){
				if(redrawAll){
					drawAllRecordings(true);
				}else{
					drawLastRecord();
				}
			}
		}
		protected function drawLastRecord() : void{
			graphBitmap.bitmapData.scroll(1,0);
			for each(var infoBundle:InfoSourceBundle in _infoBundles){
				drawRecording(infoBundle,0);
			}
		}
		protected function drawRecording(infoBundle:InfoSourceBundle, index:int) : void{
			var value:Number = infoBundle.recordings[index];
			var upper:Number = (isNaN(infoBundle.upperLimit)?infoBundle.maxRecorded:infoBundle.upperLimit);
			var lower:Number = (isNaN(infoBundle.lowerLimit)?infoBundle.minRecorded:infoBundle.lowerLimit);
			var y:int = Math.round(graphBitmap.bitmapData.height-(((value/(upper-lower))*graphBitmap.bitmapData.height)+lower));
			graphBitmap.bitmapData.fillRect(new Rectangle(0,0,1,graphBitmap.bitmapData.height),0);
			graphBitmap.bitmapData.setPixel(index,y,infoBundle.infoSource.labelColour);
		}
		protected function clearAllRecordings() : void{
			for each(var infoBundle:InfoSourceBundle in _infoBundles){
				infoBundle.maxRecorded = 0;
				infoBundle.minRecorded = 0;
				infoBundle.recordings = [];
			}
			if(graphBitmap){
				graphBitmap.bitmapData.fillRect(graphBitmap.bitmapData.rect,0);
			}
		}
		protected function drawAllRecordings(forceClear:Boolean = true) : void{
			if(graphBitmap){
				graphBitmap.bitmapData.fillRect(graphBitmap.bitmapData.rect,0);
				for each(var infoBundle:InfoSourceBundle in _infoBundles){
					drawBundle(infoBundle);
				}
			}
		}
		protected function drawBundle(infoBundle:InfoSourceBundle) : void{
			for(var x:int=0; x<infoBundle.recordings.length; x++){
				drawRecording(infoBundle,x);
			}
		}
		override protected function initialise() : void{
			super.initialise();
			graphBitmap = new Bitmap();
			addChild(graphBitmap);
		}
		override protected function draw() : void{
			if(!graphBitmap.bitmapData || graphBitmap.bitmapData.width!=width || graphBitmap.bitmapData.height!=height){
				graphBitmap.bitmapData = new BitmapData(width,height,false,0);
				drawAllRecordings(false);
			}
		}
	}
}
import au.com.thefarmdigital.debug.infoSources.INumericInfoSource;

class InfoSourceBundle{
	public var recordings:Array = [];
	public var infoSource:INumericInfoSource;
	public var maxRecorded:Number = 0;
	public var minRecorded:Number = 0;
	public var upperLimit:Number;
	public var lowerLimit:Number;
	
	public function InfoSourceBundle(infoSource:INumericInfoSource, upperLimit:Number, lowerLimit:Number){
		this.infoSource = infoSource;
		this.upperLimit = upperLimit;
		this.lowerLimit = lowerLimit;
	}
}