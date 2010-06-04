package au.com.thefarmdigital.debug.toolbar
{
	import flash.display.Shape;
	
	public class DebugHorizontalSeperator extends Shape
	{
		public function DebugHorizontalSeperator(){
			super();
			graphics.beginFill(0,0);
			graphics.drawRect(0,0,10,1);
			graphics.beginFill(0x333333);
			graphics.drawRect(2.5,0,5,1);
		}
	}
}