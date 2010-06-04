package au.com.thefarmdigital.effects
{
	import au.com.thefarmdigital.display.View;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Cylinder extends View
	{
		private static var DISPLACEMENT_X:Shape;
		private static var DISPLACEMENT_Y:Shape;
		
		private static function init():void{
			if(!DISPLACEMENT_X){
				var xColors:Array = [];
				var yColors:Array = [];
				var alphas:Array = [];
				var ratios:Array = [];
				var c:Number = (0.5*0xff);
				var max:Number = 15;
				for(var i:int=0; i<max; ++i){
					var angle:Number = ((Math.PI/(max-1))*i)-(Math.PI/2);
					var index:Number = Math.sin(angle);
					var offset:Number = ((index+1)/2)
					var depth:Number = (Math.sqrt(1-Math.pow(index,2))-(1-Math.abs(index)))*2
					var red:int = c+(depth*c)*(i>=max/2?-1:1);
					xColors.push(red << 16);
					yColors.push(Math.sqrt(1-Math.pow(index,2))*0xff);
					alphas.push(1);
					ratios.push(offset*0xff);
				}
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(1,1,0,0,0);
				DISPLACEMENT_X = new Shape();
				DISPLACEMENT_X.graphics.lineStyle(0);
				DISPLACEMENT_X.graphics.beginGradientFill(GradientType.LINEAR,xColors,alphas,ratios,matrix);
				DISPLACEMENT_X.graphics.drawRect(0,0,1,1);
				
				DISPLACEMENT_Y = new Shape();
				DISPLACEMENT_Y.graphics.lineStyle(0);
				DISPLACEMENT_Y.graphics.beginGradientFill(GradientType.LINEAR,yColors,alphas,ratios,matrix);
				DISPLACEMENT_Y.graphics.drawRect(0,0,1,1);
			}
		}
		
		
		public function get rotationX():Number{
			return _rotationX;
		}
		public function set rotationX(value:Number):void{
			if(value!=_rotationX){
				_rotationX = value;
				invalidate();
			}
		}
		public function get sideSurface():DisplayObject{
			return _sideSurface;
		}
		public function set sideSurface(value:DisplayObject):void{
			if(value!=_sideSurface){
				_sideSurface = value;
				invalidate();
			}
		}
		override public function get width():Number{
			return super.width;
		}
		override public function set width(value:Number):void{
			sizeChanged = true;
			super.width = value;
		}
		override public function get height():Number{
			return super.height;
		}
		override public function set height(value:Number):void{
			sizeChanged = true;
			super.height = value;
		}
		public function set endGradient(value:Array):void{
			if(_endGradient!=value){
				_endGradient = value;
				_endAlphas = [];
				_endRatios = [];
				var length:int = _endGradient.length;
				for(var i:int=0; i<length; ++i){
					_endAlphas.push(1);
					_endRatios.push((i/(length-1))*0xff);
				}
				invalidate();
			}
		}
		public function get endGradient():Array{
			return _endGradient;
		}
		
		
		protected var _rotationX:Number = 0;
		protected var _sideSurface:DisplayObject;
		protected var endSurface:Sprite;
		protected var renderArea:Bitmap;
		protected var displacementMap:BitmapData;
		protected var sizeChanged:Boolean = true;
		protected var _endGradient:Array = [0];
		protected var _endAlphas:Array = [1];
		protected var _endRatios:Array = [1];
		
		public function Cylinder(){
			init();
			endSurface = new Sprite();
			addChild(endSurface);
			
			// testing
			var point:Sprite = new Sprite();
			point.graphics.beginFill(0x0000ff);
			point.graphics.drawCircle(-2,-2,2);
			addChild(point);
			// end testing
		}
		override protected function draw():void{
			var rads:Number = _rotationX*(Math.PI/180);
			if(!isNaN(width) && !isNaN(height) && width && height){
				var matrix:Matrix;
				if(sizeChanged){
					sizeChanged = false;
					matrix = new Matrix();
					matrix.a = width;
					matrix.d = height+width/2;
					if(renderArea){
						removeChild(renderArea);
					}
					renderArea = new Bitmap(new BitmapData(width,height+width/2,true,0));
					addChild(renderArea);
					
					displacementMap = new BitmapData(width,height+width/2,false);
					displacementMap.draw(DISPLACEMENT_X,matrix);
					displacementMap.draw(DISPLACEMENT_Y,matrix,null,BlendMode.ADD);
					
					this.setChildIndex(endSurface,this.numChildren-1);
				}
				var sin:Number = Math.sin(rads);
				var cos:Number = Math.cos(rads);
				var offset:Number = (sin*(width/2));
				var yShift:Number = offset*(cos<0?-1:1);
				var xShift:Number = width/4;
				matrix = new Matrix();
				matrix.d = cos;
				matrix.ty = Math.abs(offset)/2+(cos<0?-height*matrix.d:0);
				renderArea.bitmapData.lock();
				renderArea.bitmapData.fillRect(new Rectangle(0,0,renderArea.bitmapData.width,renderArea.bitmapData.height),0);
				renderArea.bitmapData.draw(_sideSurface,matrix);
				renderArea.x = -width/2;
				renderArea.y = -Math.max(0,yShift)-(height/2)*Math.abs(cos);
				var filter:DisplacementMapFilter = new DisplacementMapFilter(displacementMap,new Point(0,0),BitmapDataChannel.RED,BitmapDataChannel.BLUE,xShift,yShift,DisplacementMapFilterMode.COLOR,0,0);
				renderArea.filters = [filter];
				
				endSurface.graphics.clear();
				matrix.createGradientBox(width,offset*2);
				endSurface.graphics.beginGradientFill(GradientType.RADIAL,_endGradient,_endAlphas,_endRatios,matrix);
				endSurface.graphics.drawEllipse(0,0,width,offset*2);
				endSurface.x = -width/2;
				if(offset>0)endSurface.y = (height*cos)-offset-(height/2)*cos;
				else endSurface.y = -offset-(height/2)*cos;
			}
		}
	}
}