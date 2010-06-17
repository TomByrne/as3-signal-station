package org.farmcode.actLibrary.display.visualSockets.debug
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import org.farmcode.actLibrary.display.visualSockets.SocketBundle;
	

	public class VisualSocketOutliner
	{
		public static function outlineSocket(graphics:Graphics, socketBundle:SocketBundle, recursive:Boolean=true, colors:Array=null):void{
			if(!colors){
				colors = [0xff0000,0xff00ff,0x00ff00,0x00ffff];
			}
			graphics.clear();
			_outlineSocket(graphics,socketBundle,recursive,colors,0);
		}
		private static function _outlineSocket(graphics:Graphics, socketBundle:SocketBundle, recursive:Boolean, colors:Array, gen:int):void{
			var drawSize:Rectangle = socketBundle.fillingSocket.globalPosition;
			var color:Number = colors[gen%colors.length];
			graphics.lineStyle(0,color);
			graphics.drawRect(drawSize.x,drawSize.y,drawSize.width,drawSize.height);
			if(recursive){
				var childGen:int = gen+1;
				for each(var childBundle:SocketBundle in socketBundle.childSockets){
					_outlineSocket(graphics, childBundle, recursive, colors, childGen)
				}
			}
		}
	}
}