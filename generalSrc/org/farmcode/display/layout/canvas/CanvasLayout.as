package org.farmcode.display.layout.canvas
{
	import flash.geom.Point;
	
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractSeperateLayout;
	import org.farmcode.display.layout.ILayoutSubject;
	
	public class CanvasLayout extends AbstractSeperateLayout
	{
		
		public function CanvasLayout(scopeView:IView=null){
			super(scopeView);
		}
		override protected function drawToMeasure() : Boolean{
			return false;
		}
		override protected function onSubjectMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			super.onSubjectMeasChanged(from, oldWidth, oldHeight);
			subjMeasurementsChanged(from);
		}
		override protected function measureSubject(subject:ILayoutSubject, subjMeas:Point):void{
			var meas:Point = subject.measurements;
			subjMeas.x = meas.x;
			subjMeas.y = meas.y;
		}
		override protected function layoutSubject(subject:ILayoutSubject, subjMeas:Point=null):void{
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
			}
		}
	}
}