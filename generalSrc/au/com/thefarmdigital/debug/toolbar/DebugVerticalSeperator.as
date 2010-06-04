package au.com.thefarmdigital.debug.toolbar
{
	import flash.display.Shape;
	
	public class DebugVerticalSeperator extends Shape
	{
		public function DebugVerticalSeperator(){
			super();
			graphics.beginFill(0,0);
			graphics.drawRect(0,0,1,10);
			graphics.beginFill(0x333333);
			graphics.drawRect(0,2.5,1,5);
		}
	}
}