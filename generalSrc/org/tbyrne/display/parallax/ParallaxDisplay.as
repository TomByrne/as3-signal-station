package org.tbyrne.display.parallax
{
	import org.tbyrne.display.parallax.events.ParallaxEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ParallaxDisplay extends EventDispatcher implements ILayeredParallaxDisplay
	{
		public function get parallaxParent():IParallaxDisplay{
			return _parallaxParent;
		}
		public function set parallaxParent(value:IParallaxDisplay):void{
			_parallaxParent = value;
		}
		
		public function get position():Point3D{
			return _position;
		}
		public function set position(value:Point3D):void{
			if(_position!=value){
				var oldPos:Point3D = _position;
				if (oldPos){
					oldPos.removeEventListener(ParallaxEvent.POSITION_CHANGED, this.handlePositionChange);
				}
				_position = value;
				this.position.addEventListener(ParallaxEvent.POSITION_CHANGED, this.handlePositionChange);
				
				// Dispatch events
				var oldX: Number = NaN;
				var oldY: Number = NaN;
				var oldZ: Number = NaN;
				if (oldPos != null)
				{
					oldX = oldPos.x;
					oldY = oldPos.y;
					oldZ = oldPos.z;
				}
				this.dispatchEventsForPosition((oldPos != null), oldX, oldY, oldZ);
			}
		}
		
		public function get display():DisplayObject{
			return _display;
		}
		public function set display(value:DisplayObject):void{
			if(_display!=value){
				if(_display){
					_display.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					_display.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
				}
				_display = value;
				_displayContainer = (value as DisplayObjectContainer);
				if(_display){
					_display.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					_display.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
					_addedToStage = (_display.stage!=null);
					assessCacheAsBitmap();
				}
				if(hasEventListener(ParallaxEvent.DISPLAY_CHANGED)){
					dispatchEvent(new ParallaxEvent(ParallaxEvent.DISPLAY_CHANGED));
				}
			}
		}
		public function get displayContainer():DisplayObjectContainer{
			return _displayContainer;
		}
		
		public function get cameraDepth():Number{
			return _cameraDepth;
		}
		public function set cameraDepth(value:Number):void{
			_cameraDepth = value;
		}
		public function set cacheAsBitmap(value:Boolean):void{
			if(_cacheAsBitmap!=value){
				_cacheAsBitmap = value;
				assessCacheAsBitmap();
			}
		}
		public function get cacheAsBitmap():Boolean{
			return _cacheAsBitmap;
		}
		
		public function get useLayer():Boolean{
			return _useLayer;
		}
		public function set useLayer(value:Boolean):void{
			_useLayer = value;
		}
		
		private var _useLayer:Boolean;
		private var _cacheAsBitmap:Boolean = true;
		private var _cameraDepth:Number;
		private var _display:DisplayObject;
		private var _position:Point3D;
		private var _parallaxParent:IParallaxDisplay;
		private var _displayContainer:DisplayObjectContainer;
		private var _addedToStage:Boolean;
		
		public function ParallaxDisplay(){
		}
		private function onAddedToStage(e:Event):void{
			_addedToStage = true;
			assessCacheAsBitmap();
		}
		private function onRemovedFromStage(e:Event):void{
			_addedToStage = false;
			assessCacheAsBitmap();
		}
		private function handlePositionChange(event: ParallaxEvent): void
		{
			this.dispatchEventsForPosition(true, event.previousX, event.previousY, event.previousZ);
		}
		private function dispatchEventsForPosition(hasPrevious: Boolean, prevX: Number = NaN, 
			prevY: Number = NaN, prevZ: Number = NaN): void{
			var event: ParallaxEvent;
			if(hasEventListener(ParallaxEvent.POSITION_CHANGED) && (!hasPrevious || prevX != this.position.x || prevY != this.position.y)){
				event = new ParallaxEvent(ParallaxEvent.POSITION_CHANGED);
				event.previousX = prevX;
				event.previousY = prevY;
				event.previousZ = prevZ;
				this.dispatchEvent(event);
			}
			if (hasEventListener(ParallaxEvent.DEPTH_CHANGED) && (!hasPrevious || prevZ != this.position.z)){
				event = new ParallaxEvent(ParallaxEvent.DEPTH_CHANGED);
				event.previousX = prevX;
				event.previousY = prevY;
				event.previousZ = prevZ;
				this.dispatchEvent(event);
			}
		}
		protected function assessCacheAsBitmap():void{
			// bug in flash player makes this consume excessive memory
			//if(_display)_display.cacheAsBitmap = (_cacheAsBitmap && _addedToStage);
		}
	}
}
/*
`                                      ````````````````````````````..........--://++ooossssssssyyhys
`                                           ```` ````` `    `````````.........---:://++ooossossyyyso
`                                                                `````````.........--::::////++oooo/
`                                                  .-::-`              ``````````..........---::/+/:
`                                               -ohmNNNNmho:`                 `````````````````.....
`                                          ``.+hmNNNNNNNNNNNms:`                            ````````
`                                 `.-:/++oooymNNNNNNNNNNNNNNNNNd+`                                  
`                              `/sdmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNh.                                 
`                            .omNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNs                                 
`                           -dNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN.                                
`                          .mNNNNNNNNNNNNmmNmhmNNNNNNNNNNNNNNNNNNNN/                                
.                          /NNNNNNNNNNNNd/-/o/shmmmNNNNNNNNNNNNNNNN/                                
.                          /NNNNNNNNNNNy-...../yyyhNNNNNNNNNNNNNNNNy-                               
.                         `-mNNNNNNNNNy..`````.-:/ydmNNNNNNNNNNNNNNNm+`                             
.                         ``/dNNNNNNm+...````.....:+symNNNNNNNNNNNNNNNy`                            
.                         ```sdhNNNdo............-/shdNNNNNNNNNNNNNNNNNy`                           
.                        ```.y+:NNhss.......``.--:-:+hdmNNNNNNNNNNNNNNNNo                           
.                       ````./:odNdym/....``..:s-o-:hsyhhmNNNNNNNNNNNNNNm`  `    ```                
.                       ``````..-yNdm:..-/oyhhyh:hydNmmmNNNNNNNNNNNNNNNNN. ````````` ` `            
.                        ````````yddy-./syhmmNd/.+NNNmdmNNNNNNNNNNNNNNNNy``````````````             
.                       `````````///+.`..../yy:../NNNyoydmdmNNNNNNhoyhy/.```````````````            
.                      ``````````.-:/.```...-....+NNNms//+sdNNNNmo....`````````````````             
`                  `  `````````````.+..````....../NNNNdyohmNNNmy/````````````````````` ``           
.                       ````````````--......-./:+hNNNNNmmNNNNNds.````````````````````` `            
.                        `````````````.....:-.+/ydNNNNNNNNNNNh:.````````````````````````  `         
.                   `  ````` ``````````........-s:hmNNNNNNNNN/``````````````````````````            
.                   ` ` ```````````````....+o/+syodNNNNNNNNNh.``````````````````````````  `         
`                ````````````````````.::..-/:::/+ohNNNNNNNNNo.``````````````````````````            
.                 ``````````````````:hmy.--..-+yyhmNNNNNNNNNmdo-```````````````````````             
.               ```` `````````````-omNNy.--.--+dNNNNNNNNNNNNNNNmo.``````````````````` `             
.               ```````````````./ymNNNNy..:/-../shmNNNNNNNNNNNNNNh.``````````````` `                
.              ```````````.-:+sdNNNNNNmm:..:+osydmNNNNNNNNNNNNNNNNy-````````````` ``                
.          ```````..-/+syhmNNNNNNNNNNNdNd:...:smNNNNNNNNNNNNNNNNNNNmh:.``````````` ```              
.        ```..:+shdmNNNNNNNNNNNNNNNNNNydNm+...-odNNNNNNNNNNNNNNNNNNNNNmds+-.`````` `                
.      .-/oydmNNNNNNNNNNNNNNNNNNNNNNNNhmNNNy:.-/ymmmmNNNNNNNNNNNNNNNNNNNNNNmho/-````                
.    `+dNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNdNNNdo++soooohNNNNNNNNNNNNNNNNNNNNNNNNNmds+-.`              
.   `oNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNhNNNNds+-...-syyyhdNNNNNNNNNNNNNNNNNNNNNNNNNdy+:.``         
.   /NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmNNdy+/---..-/+sNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmhs-        
.  -mNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmdddNmhsy++:-://:yNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNm:       
`  yNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNhyssy+/::yNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNd`      
` :mNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNNms+o///smNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN:      
.`hNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNdNNNs:-:+hmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNo      
`:mNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmdNNs-.sNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNh      
`yNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNNy.sNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNm.     
:mNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmsNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN+     
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNh     
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN.    
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN+    
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNy    
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNm`   


We're all mad here

You can hang me in a bottle like a cat
Let the crows pick me clean but for my hat
Where the wailing of a baby
Meets the footsteps of the dead
We're all mad here

As the devil sticks his flag into the mud
Mrs Carol has run off with Reverend Judd
Hell is such a lonely place
And your big expensive face will never last

And you'll die with the rose still on your lips
And in time the heart-shaped bone that was your hips
And the worms, they will climb the rugged ladder of your spine
We're all mad here

And my eyeballs roll this terrible terrain
And we're all inside a decomposing train
And your eyes will die like fish
And the shore of your face will turn to bone

 - tom waits
 
*/