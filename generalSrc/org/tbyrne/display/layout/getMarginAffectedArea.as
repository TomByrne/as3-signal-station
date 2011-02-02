package org.tbyrne.display.layout{
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.layout.core.ILayoutInfo;
	import org.tbyrne.display.layout.core.IMarginLayoutInfo;

	public function getMarginAffectedArea(positionX:Number, positionY:Number, sizeX:Number, sizeY:Number, layoutInfo:ILayoutInfo, fillRect:Rectangle, marginRect:Rectangle=null):void{
		var cast:IMarginLayoutInfo = (layoutInfo as IMarginLayoutInfo);
		var marginTop:Number;
		var marginLeft:Number;
		var marginRight:Number;
		var marginBottom:Number;
		if(cast){
			marginTop = (!isNaN(cast.marginTop)?cast.marginTop:0);
			marginLeft = (!isNaN(cast.marginLeft)?cast.marginLeft:0);
			marginRight = (!isNaN(cast.marginRight)?cast.marginRight:0);
			marginBottom = (!isNaN(cast.marginBottom)?cast.marginBottom:0);
		}else{
			marginTop = 0;
			marginLeft = 0;
			marginRight = 0;
			marginBottom = 0;
		}
		if(sizeX>marginLeft+marginRight){
			fillRect.x = positionX+marginLeft;
			fillRect.width = sizeX-marginLeft-marginRight;
		}else{
			fillRect.x = positionX+sizeX/2;
			fillRect.width = 0;
		}
		
		if(sizeX>marginTop+marginBottom){
			fillRect.y = positionY+marginTop;
			fillRect.height = sizeY-marginTop-marginBottom;
		}else{
			fillRect.y = positionY+sizeY/2;
			fillRect.height = 0;
		}
		
		if(marginRect){
			marginRect.x = marginLeft;
			marginRect.y = marginTop;
			marginRect.width = marginRight;
			marginRect.height = marginBottom;
		}
	}
}