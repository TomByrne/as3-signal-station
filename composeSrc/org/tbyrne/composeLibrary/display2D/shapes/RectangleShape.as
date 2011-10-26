package org.tbyrne.composeLibrary.display2D.shapes
{
	import flash.display.Graphics;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.IGraphicsStroke;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	import org.tbyrne.data.dataTypes.IValueProvider;
	import org.tbyrne.geom.rect.IRectangleProvider;
	
	public class RectangleShape extends AbstractTrait implements IDrawAwareTrait
	{
		private static const EMPTY_FILL:GraphicsSolidFill = new GraphicsSolidFill(0,0);
		private static const EMPTY_STROKE:GraphicsStroke = new GraphicsStroke();
		
		public function get rectangleProvider():IRectangleProvider{
			return _rectangleProvider;
		}
		public function set rectangleProvider(value:IRectangleProvider):void{
			if(_rectangleProvider!=value){
				if(_rectangleProvider){
					_rectangleProvider.rectangleChanged.removeHandler(onRectangleChanged);
				}
				_rectangleProvider = value;
				if(_rectangleProvider){
					_rectangleProvider.rectangleChanged.addHandler(onRectangleChanged);
				}
				invalidateDrawing();
			}
		}
		
		
		public function get fill():IGraphicsFill{
			return _fill;
		}
		public function set fill(value:IGraphicsFill):void{
			if(_fill!=value){
				_fill = value;
				invalidateDrawing();
			}
		}
		
		public function get stroke():IGraphicsStroke{
			return _stroke;
		}
		public function set stroke(value:IGraphicsStroke):void{
			if(_stroke!=value){
				_stroke = value;
				invalidateDrawing();
			}
		}
		
		public function get graphics():Graphics{
			return _graphics;
		}
		public function set graphics(value:Graphics):void{
			if(_graphics!=value){
				_graphics = value;
				invalidateDrawing();
			}
		}
		
		public function get delayDrawing():Boolean{
			return _delayDrawing;
		}
		public function set delayDrawing(value:Boolean):void{
			if(_delayDrawing!=value){
				_delayDrawing = value;
				if(!_delayDrawing && _drawingInvalid){
					draw();
				}
			}
		}
		
		private var _delayDrawing:Boolean;
		
		private var _graphics:Graphics;
		private var _stroke:IGraphicsStroke;
		private var _fill:IGraphicsFill;
		
		private var _rectangleProvider:IRectangleProvider;
		private var _drawingInvalid:Boolean;
		
		private var _drawingData:Vector.<IGraphicsData>;
		private var _drawPath:GraphicsPath;
		
		public function RectangleShape(){
			super();
			
			_drawPath = new GraphicsPath();
			
			_drawingData = new Vector.<IGraphicsData>();
			_drawingData[0] = EMPTY_FILL;
			_drawingData[1] = EMPTY_STROKE;
			_drawingData[2] = _drawPath;
			_drawingData[3] = new GraphicsEndFill();
		}
		
		private function onRectangleChanged(from:IRectangleProvider):void{
			invalidateDrawing();
		}
		
		public function tick(timeStep:Number):void{
			if(_drawingInvalid){
				draw();
			}
		}
		
		private function invalidateDrawing():void
		{
			if(_delayDrawing){
				_drawingInvalid = true;
			}else{
				draw();
			}
		}
		
		private function draw():void
		{
			_graphics.clear();
			
			if(!_rectangleProvider)return;
			
			if(isNaN(_rectangleProvider.x) || isNaN(_rectangleProvider.y) || isNaN(_rectangleProvider.width) || isNaN(_rectangleProvider.height))return;
			
			if(_fill){
				_drawingData[0] = _fill as IGraphicsData;
			}else{
				_drawingData[0] = EMPTY_FILL;
			}
			if(_stroke){
				_drawingData[1] = _stroke as IGraphicsData;
			}else{
				_drawingData[1] = EMPTY_STROKE;
			}
			_drawPath.commands = new Vector.<int>();
			_drawPath.data = new Vector.<Number>();
			
			_drawPath.moveTo(_rectangleProvider.x,_rectangleProvider.y);
			_drawPath.lineTo(_rectangleProvider.x+_rectangleProvider.width,_rectangleProvider.y);
			_drawPath.lineTo(_rectangleProvider.x+_rectangleProvider.width,_rectangleProvider.y+_rectangleProvider.height);
			_drawPath.lineTo(_rectangleProvider.x,_rectangleProvider.y+_rectangleProvider.height);
			_drawPath.lineTo(_rectangleProvider.x,_rectangleProvider.y);
			
			_graphics.drawGraphicsData(_drawingData);
			
			_drawingInvalid = false;
		}
	}
}