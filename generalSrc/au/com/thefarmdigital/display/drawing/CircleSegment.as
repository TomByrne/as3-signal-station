package au.com.thefarmdigital.display.drawing
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class CircleSegment
	{
		public static function draw(graphics:Graphics, x:Number, y:Number, radius:Number, startAngle:Number, angleDistance:Number, drawRadials:Boolean, accuracy:int=8):void{
			var span:Number = Math.PI / accuracy;
			var controlRadius:Number = radius/Math.cos(span);
			var anchorAngle:Number = (startAngle-90)/(180/Math.PI);
			var control:Number = 0;
			var startPoint:Point = new Point(x + Math.cos(anchorAngle) * radius,  y + Math.sin(anchorAngle) * radius);
			if(drawRadials){
				graphics.moveTo(x,y);
			}
			graphics.lineTo(startPoint.x,startPoint.y);
			var curves:Number = Math.ceil(accuracy/(360/angleDistance));
			var overhang:Number = (accuracy/(360/angleDistance))%1;
			for (var i:int = 0; i < curves; ++i) {
				if(i==curves-1 && overhang>0){
					control = anchorAngle + (span*overhang);
					anchorAngle = control + (span*overhang);
					controlRadius = radius / Math.cos(span*overhang)
				}else{
					control = anchorAngle + span;
					anchorAngle = control + span;
				}
				graphics.curveTo(x + Math.cos(control)*controlRadius, y+Math.sin(control)*controlRadius, x+Math.cos(anchorAngle) * radius, y+Math.sin(anchorAngle)*radius);
			}
			if(drawRadials)graphics.lineTo(x,y);
		}

	}
}