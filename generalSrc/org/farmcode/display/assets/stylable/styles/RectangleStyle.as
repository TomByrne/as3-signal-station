package org.farmcode.display.assets.stylable.styles
{
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsSolidFill;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.IGraphicsStroke;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.schemaTypes.IAssetSchema;
	
	public class RectangleStyle extends AbstractStyle implements IRectangleStyle
	{
		
		public function get fill():IGraphicsFill{
			return _fill;
		}
		public function set fill(value:IGraphicsFill):void{
			if(_fill!=value){
				_fill = value;
				compileGraphicsData();
			}
		}
		
		public function get stroke():IGraphicsStroke{
			return _stroke;
		}
		public function set stroke(value:IGraphicsStroke):void{
			if(_stroke!=value){
				_stroke = value;
				compileGraphicsData();
			}
		}
		
		public function get topLeftRounding():Number{
			return _topLeftRounding;
		}
		public function set topLeftRounding(value:Number):void{
			if(_topLeftRounding!=value){
				_topLeftRounding = value;
				compilePathData();
			}
		}
		
		public function get topRightRounding():Number{
			return _topRightRounding;
		}
		public function set topRightRounding(value:Number):void{
			if(_topRightRounding!=value){
				_topRightRounding = value;
				compilePathData();
			}
		}
		
		public function get bottomLeftRounding():Number{
			return _bottomLeftRounding;
		}
		public function set bottomLeftRounding(value:Number):void{
			if(_bottomLeftRounding!=value){
				_bottomLeftRounding = value;
				compilePathData();
			}
		}
		
		public function get bottomRightRounding():Number{
			return _bottomRightRounding;
		}
		public function set bottomRightRounding(value:Number):void{
			if(_bottomRightRounding!=value){
				_bottomRightRounding = value;
				compilePathData();
			}
		}
		public function set rounding(value:Number):void{
			_topLeftRounding = value;
			_topRightRounding = value;
			_bottomLeftRounding = value;
			_bottomRightRounding = value;
			compilePathData();
		}
		
		private var _bottomRightRounding:Number = 0;
		private var _bottomLeftRounding:Number = 0;
		private var _topRightRounding:Number = 0;
		private var _topLeftRounding:Number = 0;
		
		private var _stroke:IGraphicsStroke;
		private var _fill:IGraphicsFill;
		
		private var _pathWidth:Number;
		private var _pathHeight:Number;
		private var _scale9Grid:Rectangle = new Rectangle();
		private var _useScaleNine:Boolean;
		private var _drawingData:Vector.<IGraphicsData>;
		private var _pathData:GraphicsPath = new GraphicsPath();
		
		public function RectangleStyle(pathPattern:String=null, stateName:String=null, fill:IGraphicsFill=null, stroke:IGraphicsStroke=null, rounding:Number=0){
			super(pathPattern, stateName);
			_fill = fill;
			_stroke = stroke;
			this.rounding = rounding;
			compileGraphicsData();
		}
		override protected function isOverridenBy(otherStyle:IStyle):Boolean{
			var cast:RectangleStyle = (otherStyle as RectangleStyle);
			return (cast && cast.stateName==stateName);
		}
		override protected function canConcurrentApply(otherStyle:IStyle):Boolean{
			return !(otherStyle is RectangleStyle);
		}
		
		
		public function styleRectangle(shape:Shape, width:Number, height:Number, oldStyles:Array):Number{
			shape.graphics.clear();
			shape.graphics.drawGraphicsData(_drawingData);
			shape.scaleX = 1; // not doing this can cause an error when setting scale9Grid
			shape.scaleY = 1;
			shape.scale9Grid = _useScaleNine?_scale9Grid:null;
			shape.width = width;
			shape.height = height;
			return 0;
		}
		public function refreshRectangleStyle(shape:Shape, width:Number, height:Number, oldStyles:Array):Number{
			shape.width = width;
			shape.height = height;
			return 0;
		}
		public function unstyleRectangle(shape:Shape):Number{
			shape.graphics.clear();
			return 0;
		}
		
		public function compilePathData():void{
			var commands:Vector.<int> = new Vector.<int>();
			var data:Vector.<Number> = new Vector.<Number>();
			
			var maxLeft:Number = Math.max(_topLeftRounding,_bottomLeftRounding);
			var maxRight:Number = Math.max(_topRightRounding,_bottomRightRounding);
			var maxTop:Number = Math.max(_topLeftRounding,_topRightRounding);
			var maxBottom:Number = Math.max(_bottomLeftRounding,_bottomRightRounding);
			
			_pathWidth = 10+maxLeft+maxRight;
			_pathHeight = 10+maxTop+maxBottom;
			
			_useScaleNine = false;
			
			if(_topLeftRounding==0){
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(0,0);
			}else{
				drawArc(commands,data,_topLeftRounding,_topLeftRounding,_topLeftRounding,90,-90);
				_useScaleNine = true;
			}
			if(_topRightRounding==0){
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(_pathWidth,0);
			}else{
				drawArc(commands,data,_pathWidth-_topRightRounding,_topRightRounding,_topRightRounding,90,0);
				_useScaleNine = true;
			}
			if(_bottomRightRounding==0){
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(_pathWidth,_pathHeight);
			}else{
				drawArc(commands,data,_pathWidth-_bottomRightRounding,_pathHeight-_bottomRightRounding,_bottomRightRounding,90,90);
				_useScaleNine = true;
			}
			if(_bottomLeftRounding==0){
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(0,_pathHeight);
			}else{
				drawArc(commands,data,_bottomLeftRounding,_pathHeight-_bottomLeftRounding,_bottomLeftRounding,90,180);
				_useScaleNine = true;
			}
			
			commands.push(GraphicsPathCommand.LINE_TO);
			data.push(data[0],data[1]);
			
			_scale9Grid.x = maxLeft;
			_scale9Grid.y = maxTop;
			_scale9Grid.width = _pathWidth-maxLeft-maxRight;
			_scale9Grid.height = _pathHeight-maxTop-maxBottom;
			
			_pathData.commands = commands;
			_pathData.data = data;
		}
		public function compileGraphicsData():void{
			_drawingData = new Vector.<IGraphicsData>();
			if(_fill || _stroke){
				if(_stroke)_drawingData.push(_stroke);
				if(_fill)_drawingData.push(_fill);
			}else{
				_drawingData.push(new GraphicsSolidFill(0,0));
			}
			_drawingData.push(_pathData);
			_drawingData.push(new GraphicsEndFill());
		}
		
		/**
		 * @param x The x position of the centre of the arc
		 * @param y The y position of the centre of the arc
		 * @param radius radius of Arc. If [optional] yRadius is defined, then r is the x radius
		 * @param arc sweep of the arc. Negative values draw clockwise.
		 * @param startAngle starting angle in degrees.
		 * @param yRadius [optional] y radius of arc.
		 */
		protected function drawArc(commands:Vector.<int>, data:Vector.<Number>, x:Number, y:Number, radius:Number, arc:Number, startAngle:Number, yRadius:Number=NaN):void{
			if (isNaN(yRadius)) {
				yRadius = radius;
			}
			
			if (Math.abs(arc)>360) {
				arc = 360;
			}
			/*
			The math requires radians rather than degrees. To convert from degrees
			use the formula (degrees/180)*Math.PI to get radians. We use the nagative
			because we wan't angle to increase in a clockwise manner, not the anti-clockwise
			manner of normal geometry
			*/
			const radians:Number = (Math.PI/180);
			/*
			We shift our angle values so that they are registered north instead of the easterly
			orientation of normal geometry
			*/
			const shift:Number = -Math.PI/2;
			/*
			Flash uses 8 segments per circle, to match that, we draw in a maximum
			of 45 degree segments.
			*/
			const maxAngPerSeg:Number = Math.PI/4;// (360/8)*(Math.PI/180)
			
			arc = (arc*radians);
			startAngle = (startAngle*radians)+shift;
			
			var segs:int = Math.ceil(Math.abs(arc)/maxAngPerSeg);
			var normalSize:Number = arc<0?-maxAngPerSeg:maxAngPerSeg;
			var leftOver:Number = arc%maxAngPerSeg;
			if(!leftOver)leftOver = maxAngPerSeg;
			
			// find our starting points (ax,ay) relative to the secified x,y
			var startX:Number = x+Math.cos(startAngle)*radius;
			var startY:Number = y+Math.sin(startAngle)*yRadius;
			
			if(data.length)commands.push(GraphicsPathCommand.LINE_TO);
			else commands.push(GraphicsPathCommand.MOVE_TO);
			
			data.push(startX);
			data.push(startY);
			
			// Loop for drawing arc segments
			for (var i:int = 0; i<segs; i++) {
				var theta:Number = (i<segs-1?normalSize:leftOver);
				// find the angle halfway between the last angle and the new
				var angleMid:Number = startAngle+(theta/2);
				// increment our angle
				startAngle += theta;
				// calculate our end point
				var bx:Number = x+Math.cos(startAngle)*radius;
				var by:Number = y+Math.sin(startAngle)*yRadius;
				// calculate our control point
				var cx:Number = x+Math.cos(angleMid)*(radius/Math.cos(theta/2));
				var cy:Number = y+Math.sin(angleMid)*(yRadius/Math.cos(theta/2));
				
				commands.push(GraphicsPathCommand.CURVE_TO);
				data.push(cx);
				data.push(cy);
				data.push(bx);
				data.push(by);
			}
		}
	}
}