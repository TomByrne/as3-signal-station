package org.farmcode.display.layout.canvas
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractLayout;
	import org.farmcode.display.layout.ILayoutSubject;
	
	public class CanvasLayout extends AbstractLayout
	{
		
		public function CanvasLayout(scopeView:IView=null){
			super(scopeView);
		}
		override protected function drawSubject(subject:ILayoutSubject) : void{
			var cast:ICanvasLayoutInfo = (subject.layoutInfo as ICanvasLayoutInfo);
			if(cast){
				var measurements:Point = subject.measurements;
				var hasMeasurements:Boolean = (measurements!=null);
				
				var x:Number;
				var width:Number;
				var hasLeft:Boolean = (!isNaN(cast.left));
				var hasRight:Boolean = (!isNaN(cast.right));
				var hasCentre:Boolean = (!isNaN(cast.centre));
				
				if(hasLeft && hasRight){
					width = _displayPosition.width-cast.left-cast.right;
				}else if(!isNaN(cast.width)){
					width = cast.width;
				}else if(!isNaN(cast.percentWidth)){
					width = (cast.percentWidth/100)*_displayPosition.width;
				}else if(hasMeasurements){
					width = measurements.x;
				}else{
					width = _displayPosition.width;
				}
				
				if(hasLeft){
					x = _displayPosition.x+cast.left;
				}else if(hasRight){
					x = _displayPosition.x+_displayPosition.width-cast.right-width;
				}else if(hasCentre){
					x = _displayPosition.x+_displayPosition.width/2-cast.middle-width/2;
				}else if(hasMeasurements){
					x = _displayPosition.x+measurements.x;
				}else{
					x = _displayPosition.x;
				}
				
				var y:Number;
				var height:Number;
				var hasTop:Boolean = (!isNaN(cast.top));
				var hasBottom:Boolean = (!isNaN(cast.bottom));
				var hasMiddle:Boolean = (!isNaN(cast.middle));
				
				if(hasTop && hasBottom){
					height = _displayPosition.height-cast.top-cast.bottom;
				}else if(!isNaN(cast.height)){
					height = cast.height;
				}else if(!isNaN(cast.percentHeight)){
					height = (cast.percentHeight/100)*_displayPosition.height;
				}else if(hasMeasurements){
					height = measurements.y;
				}else{
					height = _displayPosition.height;
				}
				
				if(hasTop){
					y = _displayPosition.y+cast.top;
				}else if(hasBottom){
					y = _displayPosition.y+_displayPosition.height-cast.bottom-height;
				}else if(hasBottom){
					y = _displayPosition.y+_displayPosition.height/2-cast.middle-height/2;
				}else if(hasMeasurements){
					y = _displayPosition.y+measurements.y;
				}else{
					y = _displayPosition.y;
				}
				subject.setDisplayPosition(x,y,width,height);
				
				// TODO: the measurements shuold really just be the measurements of the subject
				addToMeas(width,height);
			}else{
				super.drawSubject(subject);
			}
		}
	}
}