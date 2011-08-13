package org.tbyrne.media.image
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.errors.ScriptTimeoutError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.bytearray.gif.decoder.GIFDecoder;
	import org.bytearray.gif.errors.FileTypeError;
	import org.bytearray.gif.events.GIFPlayerEvent;
	import org.bytearray.gif.events.TimeoutEvent;
	import org.bytearray.gif.frames.GIFFrame;
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	import org.tbyrne.display.assets.nativeTypes.ILoader;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.frame.FrameLayoutInfo;
	
	public class GifSource extends ImageSource
	{
		override public function set imageUrl(value:String):void{
			_isGif = false;
			super.imageUrl = value;
		}
		
		public function get playing():Boolean{
			return _playing;
		}
		public function set playing(value:Boolean):void{
			if(_playing!=value){
				_playing = value;
				if(_isGif){
					if(value){
						play();
					}else{
						stop();
					}
				}
			}
		}
		
		private var _playing:Boolean = true;
		
		private var gifDecoder:GIFDecoder;
		private var aFrames:Array;
		private var myTimer:Timer;
		private var iInc:int;
		private var iIndex:int;
		private var auto:Boolean;
		private var arrayLng:uint;
		protected var _isGif:Boolean;
		protected var _bitmapData:BitmapData;
		
		public function GifSource(url:String=null, smoothing:Boolean=true){
			super(url, smoothing);
			
			
			aFrames = new Array();
			
			myTimer = new Timer( 0, 0 );
			myTimer.addEventListener ( TimerEvent.TIMER, update );
			
			gifDecoder = new GIFDecoder();
		}
		override protected function createMediaDisplay():ILayoutView{
			var loader:Loader = new Loader();
			var loaderAsset:ILoader = _nativeFactory.getNew(loader);
			var bitmap:Bitmap = new Bitmap();
			var bitmapAsset:IBitmap = _nativeFactory.getNew(bitmap);
			var view:GifView = new GifView(loaderAsset, bitmapAsset,_measurements,smoothing);
			view.layoutInfo = new FrameLayoutInfo();
			if(_loaded){
				if(_isGif){
					view.bitmapData = _bitmapData;
					view.isGif = true;
				}else{
					loader.loadBytes(_urlLoader.data);
				}
			}
			
			return view;
		}
		override protected function destroyMediaDisplay(value:ILayoutView):void{
			(value as GifView).dispose();
		}
		override protected function onLoadComplete(e:Event):void{
			
			var pBytes:ByteArray = e.target.data;
			var gifStream:ByteArray = pBytes;
			
			aFrames = new Array;
			iInc = 0;
			
			try 
			{
				gifDecoder.read ( gifStream );
				
				var size:Rectangle = gifDecoder.getFrameSize();
				updateDisplayMeasurements(size.width,size.height);
				
				var lng:int = gifDecoder.getFrameCount();
				
				for ( var i:int = 0; i< lng; i++ ) 
					aFrames[int(i)] = gifDecoder.getFrame(i);
				
				arrayLng = aFrames.length;
				
				_playing ? play() : gotoAndStop (1);
				
				
				_loaded = true;
				/*for(var i:* in _allMediaDisplays){
					var view:MediaView = (i as MediaView);
					var loader:ILoader = (view.asset as ILoader);
					loader.loadBytes(_urlLoader.data);
				}*/
				setMemoryLoadProps(_urlLoader.bytesLoaded, _urlLoader.bytesTotal);
				
				_isGif = true;
				for(var gifView:* in _allMediaDisplays){
					gifView.isGif = true;
				}
				
			} catch ( e:ScriptTimeoutError ){	
				Log.log(Log.DEV_ERROR,"Gif took too long to decode: "+_imageUrl);
			} catch ( e:FileTypeError ){	
				super.onLoadComplete(e);	
			}
		}
		private function update ( pEvt:TimerEvent ) :void
		{
			var delay:int = aFrames[ int(iIndex = iInc++ % arrayLng) ].delay;
			
			pEvt.target.delay = ( delay > 0 ) ? delay : 100;
			
			switch ( gifDecoder.disposeValue ) 
			{		
				case 1:
					if ( !iIndex ) 
						_bitmapData = aFrames[ 0 ].bitmapData.clone();
					_bitmapData.draw ( aFrames[ iIndex ].bitmapData );
					break
				case 2:
					_bitmapData = aFrames[ iIndex ].bitmapData;
					break;
			}
			
			setBitmapData();
		}
		
		private function setBitmapData():void{
			for(var gifView:* in _allMediaDisplays){
				gifView.bitmapData = _bitmapData;
			}
		}
		
		
		private function concat ( pIndex:int ):int
		{	
			_bitmapData.lock();
			for (var i:int = 0; i< pIndex; i++ ) 
				_bitmapData.draw ( aFrames[ i ].bitmapData );
			_bitmapData.unlock();
			
			return i;
		}
		
		/*override protected function createMediaDisplay():ILayoutView{
			super.createMediaDisplay();
		}
		override protected function destroyMediaDisplay(value:ILayoutView):void{
			super.destroyMediaDisplay(value);
		}*/
		
		
		/**
		 * Start playing
		 *
		 * @return void
		 */
		private function play ():void
		{	
			if ( aFrames.length > 0 ) 
			{	
				if ( !myTimer.running ) 
					myTimer.start();
				
			} else throw new Error ("Nothing to play");
		}
		
		/**
		 * Stop playing
		 *
		 * @return void
		 */
		private function stop ():void
		{
			if ( myTimer.running ) 
				myTimer.stop();	
		}
		
		/**
		 * Returns current frame being played
		 *
		 * @return frame number
		 */
		public function get currentFrame ():int
		{
			return iIndex+1;	
		}
		public function set currentFrame(value:int):void{
			if(_playing){
				gotoAndPlay(value);
			}else{
				gotoAndStop(value);
			}
		}
		
		/**
		 * Returns GIF's total frames
		 *
		 * @return number of frames
		 */
		public function get totalFrames ():int
		{	
			return aFrames.length;	
		}
		
		/**
		 * Returns how many times the GIF file is played
		 * A loop value of 0 means repeat indefinitiely.
		 *
		 * @return loop value
		 */
		public function get loopCount ():int
		{
			return gifDecoder.getLoopCount();	
		}
		
		/**
		 * Returns is the autoPlay value
		 *
		 * @return autoPlay value
		 */
		public function get autoPlay ():Boolean
		{
			return auto;	
		}
		
		/**
		 * Returns an array of GIFFrame objects
		 *
		 * @return aFrames
		 */
		public function get frames ():Array
		{
			return aFrames;	
		}
		
		/**
		 * Moves the playhead to the specified frame and stops playing
		 *
		 * @return void
		 */
		private function gotoAndStop (pFrame:int):void
		{
			if ( pFrame >= 1 && pFrame <= aFrames.length ) 	
			{
				if ( pFrame == currentFrame ) return;
				iIndex = iInc = int(int(pFrame)-1);
				
				switch ( gifDecoder.disposeValue ) 
				{
					case 1:
						_bitmapData = aFrames[ 0 ].bitmapData.clone();
						_bitmapData.draw ( aFrames[ concat ( iInc ) ].bitmapData );
						break
					case 2:
						_bitmapData = aFrames[ iInc ].bitmapData;
						break;
				}
				
				setBitmapData();
				
				if ( myTimer.running ) 
					myTimer.stop();
				
			} else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
		}
		
		/**
		 * Starts playing the GIF at the frame specified as parameter
		 *
		 * @return void
		 */
		private function gotoAndPlay (pFrame:int):void
		{	
			if ( pFrame >= 1 && pFrame <= aFrames.length ) 
			{	
				if ( pFrame == currentFrame ) return;
				iIndex = iInc = int(int(pFrame)-1);
				
				switch ( gifDecoder.disposeValue ) 
				{	
					case 1:
						_bitmapData = aFrames[ 0 ].bitmapData.clone();
						_bitmapData.draw ( aFrames[ concat ( iInc ) ].bitmapData );
						break
					case 2:
						_bitmapData = aFrames[ iInc ].bitmapData;
						break;		
				}
				setBitmapData();
				if ( !myTimer.running ) myTimer.start();
				
			} else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
		}
		
		/**
		 * Retrieves a frame from the GIF file as a BitmapData
		 *
		 * @return BitmapData object
		 */
		private function getFrame ( pFrame:int ):GIFFrame
		{
			var frame:GIFFrame;
			
			if ( pFrame >= 1 && pFrame <= aFrames.length ) 
				frame = aFrames[ pFrame-1 ];
				
			else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
			
			return frame;	
		}
		
		/**
		 * Retrieves the delay for a specific frame
		 *
		 * @return int
		 */
		private function getDelay ( pFrame:int ):int
		{
			var delay:int;
			
			if ( pFrame >= 1 && pFrame <= aFrames.length )
				delay = aFrames[ pFrame-1 ].delay;
				
			else throw new RangeError ("Frame out of range, please specify a frame between 1 and " + aFrames.length );
			
			return delay;	
		}
	}
}