package org.tbyrne.display.layout.canvas
{
	import flash.geom.Point;
	
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.AbstractSeperateLayout;
	import org.tbyrne.display.layout.ILayoutSubject;
	
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
					width = _size.x-cast.left-cast.right;
				}else if(!isNaN(cast.width)){
					width = cast.width;
				}else if(!isNaN(cast.percentWidth)){
					width = (cast.percentWidth/100)*_size.x;
				}else if(hasMeasurements){
					width = measurements.x;
				}else{
					width = _size.x;
				}
				
				if(hasLeft){
					x = _position.x+cast.left;
				}else if(hasRight){
					x = _position.x+_size.x-cast.right-width;
				}else if(hasCentre){
					x = _position.x+_size.x/2-cast.middle-width/2;
				}else if(hasMeasurements){
					x = _position.x+measurements.x;
				}else{
					x = _position.x;
				}
				
				var y:Number;
				var height:Number;
				var hasTop:Boolean = (!isNaN(cast.top));
				var hasBottom:Boolean = (!isNaN(cast.bottom));
				var hasMiddle:Boolean = (!isNaN(cast.middle));
				
				if(hasTop && hasBottom){
					height = _size.y-cast.top-cast.bottom;
				}else if(!isNaN(cast.height)){
					height = cast.height;
				}else if(!isNaN(cast.percentHeight)){
					height = (cast.percentHeight/100)*_size.y;
				}else if(hasMeasurements){
					height = measurements.y;
				}else{
					height = _size.y;
				}
				
				if(hasTop){
					y = _position.y+cast.top;
				}else if(hasBottom){
					y = _position.y+_size.y-cast.bottom-height;
				}else if(hasBottom){
					y = _position.y+_size.y/2-cast.middle-height/2;
				}else if(hasMeasurements){
					y = _position.y+measurements.y;
				}else{
					y = _position.y;
				}
				subject.setPosition(x,y);
				subject.setSize(width,height);
			}
		}
	}
}