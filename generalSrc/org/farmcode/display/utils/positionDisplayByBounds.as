package org.farmcode.display.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public function positionDisplayByBounds(displayObject:DisplayObject, x:Number, y:Number, width:Number, height:Number):void{
		var innerBounds:Rectangle = displayObject.getBounds(displayObject);
		if(displayObject is TextField){
			// strange gutter behaviour with TextFields
			innerBounds.x += 2;
			innerBounds.y += 2;
		}
		displayObject.x = x-(innerBounds.x*(width/innerBounds.width));
		displayObject.y = y-(innerBounds.y*(height/innerBounds.height));
		displayObject.width = width;
		displayObject.height = height;
	}
}