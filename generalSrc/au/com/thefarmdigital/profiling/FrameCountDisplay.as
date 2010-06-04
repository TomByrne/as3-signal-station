package au.com.thefarmdigital.profiling
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class FrameCountDisplay extends TextField
	{
		private var fs: int;
		private var ms: int;
		
		public function FrameCountDisplay()
		{
			var format: TextFormat = new TextFormat();
			
			format.color = 0;
			format.size = 10;
			format.bold = true;
			format.font = 'Verdana';
			
			textColor = 0xcecece;
			autoSize = "left";
			defaultTextFormat = format;
			
			ms = getTimer();
			fs = 0;
			
			addEventListener( Event.ADDED, onAdded );	
			addEventListener( Event.REMOVED, onRemoved );
			blendMode = BlendMode.INVERT;
		}
		
		private function onAdded( event: Event ): void
		{
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( Event.RESIZE, onAlign );
			onAlign( new Event( Event.RESIZE ) );
		}
		
		private function onRemoved( event: Event ): void
		{
			stage.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.removeEventListener( Event.RESIZE, onAlign );
		}
		
		private function onAlign( event:Event ):void
		{
			x = int( stage.stageWidth - 22 );
		}
		
		private function onEnterFrame( event: Event ): void
		{
			if( getTimer() - 1000 > ms )
			{
				ms = getTimer();
				text = fs.toString();
				fs = 0;
			}
			else
			{
				++fs;
			}
		}
	}
}