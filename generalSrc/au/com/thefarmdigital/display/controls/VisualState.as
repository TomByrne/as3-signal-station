package au.com.thefarmdigital.display.controls
{
	
	import flash.display.DisplayObject;
	
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	public class VisualState
	{
		[Property(toString="true",clonable="true")]
		public var background:DisplayObject;
		[Property(toString="true",clonable="true")]
		public var name:String;
		[Property(toString="true",clonable="true")]
		public var fontColor:Number;
		
		public function VisualState(name:String, background:DisplayObject, fontColor:Number=NaN){
			this.background = background;
			this.name = name;
			this.fontColor = fontColor;
		}
		
		public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}