package org.farmcode.display.utils
{
	import flash.geom.Rectangle;
	
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Fit;
	import org.farmcode.display.constants.Scale;

	public class DisplayFramer
	{
		public static function frame(displayWidth:Number, displayHeight:Number, fitArea:Rectangle, anchor:String, scaleXPolicy:String, scaleYPolicy:String, fitPolicy:String, displayXOffset:Number=0, displayYOffset:Number=0):Rectangle{
			var scaleX:Number = 1;
			var scaleY:Number = 1;
			var ret:Rectangle = new Rectangle();
			if(!isNaN(displayWidth) && !isNaN(displayHeight)){
				var scaling:Boolean = false;
				if(scaleXPolicy==Scale.NEVER){
					ret.width = displayWidth;
				}else{
					scaling = true;
					scaleX = fitArea.width/displayWidth;
					if(scaleXPolicy==Scale.UP_ONLY){
						scaleX = Math.max(scaleX,1);
					}else if(scaleXPolicy==Scale.DOWN_ONLY){
						scaleX = Math.min(scaleX,1);
					}
				}
				if(scaleYPolicy==Scale.NEVER){
					ret.height = displayHeight;
				}else{
					scaling = true;
					scaleY = fitArea.height/displayHeight;
					if(scaleYPolicy==Scale.UP_ONLY){
						scaleY = Math.max(scaleY,1);
					}else if(scaleYPolicy==Scale.DOWN_ONLY){
						scaleY = Math.min(scaleY,1);
					}
				}
				if(scaling){
					if(fitPolicy==Fit.EXACT){
						scaleX = scaleY = Math.max(scaleX,scaleY);
					}else if(fitPolicy==Fit.INSIDE){
						scaleX = scaleY = Math.min(scaleX,scaleY);
					}
					ret.width = displayWidth*scaleX;
					ret.height = displayHeight*scaleY;
				}
			}else{
				ret.width = fitArea.width;
				ret.height = fitArea.height;
			}
			
			// positioning
			if(anchor.indexOf(Anchor.LEFT)!=-1)ret.x = fitArea.x;
			else if(anchor.indexOf(Anchor.RIGHT)!=-1)ret.x = fitArea.x+fitArea.width-ret.width;
			else ret.x = fitArea.x+(fitArea.width-ret.width)/2;
			
			if(anchor.indexOf(Anchor.TOP)!=-1)ret.y = fitArea.y;
			else if(anchor.indexOf(Anchor.BOTTOM)!=-1)ret.y = fitArea.y+fitArea.height-ret.height;
			else ret.y = fitArea.y+(fitArea.height-ret.height)/2;
			
			ret.x -= displayXOffset*scaleX;
			ret.y -= displayYOffset*scaleY;
			
			return ret;
		}
	}
}