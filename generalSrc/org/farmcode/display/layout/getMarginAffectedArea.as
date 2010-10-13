package org.farmcode.display.layout{
	import flash.geom.Rectangle;
	
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.core.IMarginLayoutInfo;

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
		fillRect.x = positionX+marginLeft;
		fillRect.y = positionY+marginTop;
		fillRect.width = sizeX-marginLeft-marginRight;
		fillRect.height = sizeY-marginTop-marginBottom;
		
		if(marginRect){
			marginRect.x = marginTop;
			marginRect.y = marginLeft;
			marginRect.width = marginRight;
			marginRect.height = marginBottom;
		}
	}
}