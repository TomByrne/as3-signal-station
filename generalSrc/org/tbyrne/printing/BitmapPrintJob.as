package org.tbyrne.printing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOrientation;
	
	/**
	 * The BitmapPrintJob class overcomes several issues with Flash Player's print API.
	 * Firstly, flash doesn't convert it's vector shapes to a format that most printer's can read.
	 * Secondly, after a certain amount of vector shapes or text is reached, the PrintJob's
	 * built in bitmap rendering capability breaks, printing a blank page.
	 * This class overcomes these issues by rendering a DisplayObject to a Bitmap before adding 
	 * it to the PrintJob.
	 */
	public class BitmapPrintJob extends PrintJob
	{
		public function BitmapPrintJob(){
			super();
		}
		public function addBitmapPage(display:DisplayObject, printArea:Rectangle=null, resolutionScale:Number=1):void{
			if(!printArea){
				printArea = display.getBounds(display);
			}
			
			var rotate:Boolean;
			if(orientation==PrintJobOrientation.LANDSCAPE){
				if(printArea.height>printArea.width){
					rotate = true;
				}
			}else if(printArea.height<printArea.width){
				rotate = true;
			}
			
			
			var pageScale:Number; // the scale we need to apply to the bitmap to fit it on the page
			var bitmapData:BitmapData;
			var centerX:Number = resolutionScale*((printArea.width*pageScale)-pageWidth)/2;
			var centerY:Number = resolutionScale*((printArea.height*pageScale)-pageHeight)/2;
			if(rotate){
				pageScale = Math.min(pageHeight/printArea.width,pageWidth/printArea.height);
				bitmapData = new BitmapData(pageHeight*resolutionScale, pageWidth*resolutionScale,false,0xffffff);
				centerX = resolutionScale*((printArea.width*pageScale)-pageHeight)/2;
				centerY = resolutionScale*((printArea.height*pageScale)-pageWidth)/2;
			}else{
				pageScale = Math.min(pageHeight/printArea.height,pageWidth/printArea.width);
				bitmapData = new BitmapData(pageWidth*resolutionScale, pageHeight*resolutionScale,false,0xffffff);
				centerX = resolutionScale*((printArea.width*pageScale)-pageWidth)/2;
				centerY = resolutionScale*((printArea.height*pageScale)-pageHeight)/2;
			}
			
			
			var clipRect:Rectangle = printArea.clone();
			clipRect.x -= printArea.x+centerX;
			clipRect.y -= printArea.y+centerY;
			clipRect.width *= resolutionScale*pageScale;
			clipRect.height *= resolutionScale*pageScale;
			
			var matrix:Matrix = new Matrix();
			matrix.tx = -printArea.x;
			matrix.ty = -printArea.y;
			matrix.scale(resolutionScale*pageScale,resolutionScale*pageScale);
			matrix.tx -= centerX;
			matrix.ty -= centerY;
			
			var sprite:Sprite = new Sprite();
			var bitmap:Bitmap = new Bitmap(bitmapData);
			bitmapData.draw(display,matrix,display.transform.colorTransform,null,clipRect);
			sprite.addChild(bitmap);
			if(rotate){
				bitmap.rotation = 90;
			}
			bitmap.scaleX = bitmap.scaleY = 1/resolutionScale;
			addPage(sprite);
			bitmapData.dispose();
		}
	}
}