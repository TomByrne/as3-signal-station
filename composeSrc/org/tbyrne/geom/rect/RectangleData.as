package org.tbyrne.geom.rect
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	
	public class RectangleData extends AbstractRectangleData{
		
		
		
		public function RectangleData()
		{
		}
		
		public function setRectangle(x:Number, y:Number, width:Number, height:Number):void{
			_setRectangle(x,y,width,height);
		}
	}
}