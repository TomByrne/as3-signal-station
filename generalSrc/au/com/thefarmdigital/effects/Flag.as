package au.com.thefarmdigital.effects{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class Flag extends AnimatedEffect
	{
		static private const SHADOW_MULTIPLIER:Number = 4;
		static private const HIGHLIGHT_MULTIPLIER:Number = 0.75;
		static private const X_DISP_MULTIPLIER:Number = 0.15;
		static private const Y_DISP_MULTIPLIER:Number = 0.5;
		static private const SPEED_MULTIPLIER_1:Number = 0.1;
		static private const SPEED_MULTIPLIER_2:Number = 0.075;
		static private const ORIGIN: Point = new Point();
		static private const IDENTITY: Matrix = new Matrix();
		static private const GREY_FILTER: ColorMatrixFilter = new ColorMatrixFilter(
							[
								0, 0, .35, 0, 0,
								0, 0, .35, 0, 0,
								0, 0, .35, 0, 0,
								0, 0, .35, .65, 0
							]);
		
		static public const TETHER_TOP:String = "top";
		static public const TETHER_LEFT:String = "left";
		static public const TETHER_BOTTOM:String = "bottom";
		static public const TETHER_RIGHT:String = "right";
		
		public function get tether():String{
			return _tether;
		}
		public function set tether(value:String):void{
			_tether = value;
			invalidate();
		}
		public function get windSpeed():Number{
			return _windSpeed;
		}
		public function set windSpeed(value:Number):void{
			_windSpeed = value;
			invalidate();
		}
		public function get windStrength():Number{
			return super.amount;
		}
		public function set windStrength(value:Number):void{
			super.amount = value;
			invalidate();
		}
		public function get shadows():Number{
			return _shadows;
		}
		public function set shadows(value:Number):void{
			_shadows = value;
			var cont:Number = 1+(SHADOW_MULTIPLIER*value);
			var offs:Number = 0xff-(0xff*value);
			_shadowContrast = new ColorTransform( cont, cont, cont, 1, offs, offs, offs, 0 );
			invalidate();
		}
		public function get highlights():Number{
			return _highlights;
		}
		public function set highlights(value:Number):void{
			_highlights = value;
			var cont:Number = 1+(HIGHLIGHT_MULTIPLIER*value);
			var offs:Number = (0xff*value)-0xff;
			_highlightContrast = new ColorTransform( cont, cont, cont, 1, offs, offs, offs, 0 );
			invalidate();
		}
		override public function set subject(value:DisplayObject):void {
			if(super.subject != value && value != null){
				super.subject = value;
			}
		}
		override public function get subject():DisplayObject {
			return super.subject;
		}
		
		private var _tether:String = TETHER_LEFT;
		private var _perlinNoiseOffset: Array;
		private var _windSpeed: Number = .5;
		private var _shadows: Number;
		private var _shadowContrast: ColorTransform;
		private var _highlights: Number;
		private var _highlightContrast: ColorTransform;
		private var _gradientBitmapData: BitmapData; // fix fabric on the left
		private var _flagBitmapData	: BitmapData;
		private var _greyBitmapData	: BitmapData;
		private var _subjectBitmapData	: BitmapData;
		private var _perlinNoiseBitmapData: BitmapData;
		private var _lightBitmapData: BitmapData;
		private var _perlinNoiseSeed: Number;
		private var _displacement: DisplacementMapFilter;
		
		public function Flag( subject:DisplayObject=null ){
			super(subject);
			_perlinNoiseSeed = Math.floor( Math.random() * 256 );
			_perlinNoiseOffset = [ new Point(), new Point() ];
			shadows = 1;
			highlights = 1;
			windStrength = 0.5;
		}
		
		override protected function createBitmap(): void
		{
			var vertical:Boolean = (tether==TETHER_TOP||tether==TETHER_BOTTOM);
			var xDispMult:Number = (vertical?Y_DISP_MULTIPLIER:X_DISP_MULTIPLIER);
			var yDispMult:Number = (vertical?X_DISP_MULTIPLIER:Y_DISP_MULTIPLIER);
			subjectBounds = subject.getBounds(renderArea.parent);
			var renderWidth:Number = Math.ceil(subjectBounds.width+(windStrength*0xff*xDispMult)*(vertical?2:1));
			var renderHeight:Number = Math.ceil(subjectBounds.height+(windStrength*0xff*yDispMult)*(vertical?1:2));
			if(!renderWidth || !renderHeight)return;
			if(!_flagBitmapData || renderWidth!=_flagBitmapData.width || renderHeight!=_flagBitmapData.height){
				var angle:Number;
				switch(tether){
					case TETHER_TOP:
						angle = 90;
						break;
					case TETHER_BOTTOM:
						angle = 270;
						break;
					case TETHER_LEFT:
						angle = 0;
						break;
					case TETHER_RIGHT:
						angle = 180;
						break;
				}
				angle *= Math.PI/180;
				
				//-- init flag
				if(_flagBitmapData){
					_flagBitmapData.dispose();
				}
				_flagBitmapData = new BitmapData( renderWidth, renderHeight, true, 0 );
				_renderOffset = new Point( vertical?(subjectBounds.width-renderWidth) / 2:0, vertical?0:(subjectBounds.height-renderHeight) / 2);
				
				if(_gradientBitmapData){
					_gradientBitmapData.dispose();
				}
				_gradientBitmapData = createGradientBitmap(renderWidth,renderHeight,angle,_renderOffset);
				
				//-- init 2 octaves perlinNoise
				if(_perlinNoiseBitmapData){
					_perlinNoiseBitmapData.dispose();
				}
				_perlinNoiseBitmapData = new BitmapData( renderWidth, renderHeight, false, 0 );
				
				//-- initDisplacementMapFilter
				_displacement = new DisplacementMapFilter( _perlinNoiseBitmapData, ORIGIN, 2, 4, windStrength*0xff*xDispMult, windStrength*0xff*yDispMult, 'ignore' );
				
				//-- init light
				if(_lightBitmapData){
					_lightBitmapData.dispose();
				}
				_lightBitmapData = new BitmapData( renderWidth, renderHeight, true, 0 );
				_bitmapChanged = true;
				
				if(_subjectBitmapData){
					_subjectBitmapData.dispose();
				}
				_subjectBitmapData = new BitmapData(renderWidth,renderHeight,true,0);
			}
			if(_bitmapChanged){
				var matrix:Matrix = subject.transform.matrix;
				matrix.tx = -_renderOffset.x;
				matrix.ty = -_renderOffset.y;
				_subjectBitmapData.draw(subject,matrix);
				_bitmapChanged = false;
				subject.visible = false;
			}
			
			
			//-- clear output
			_flagBitmapData.lock();
			_flagBitmapData.fillRect( _flagBitmapData.rect, 0 );
			
			//-- apply wind
			if(vertical){
				_perlinNoiseOffset[0].y += windSpeed*SPEED_MULTIPLIER_1 * subjectBounds.width * (tether==TETHER_TOP?-1:1);
				_perlinNoiseOffset[1].y += windSpeed*SPEED_MULTIPLIER_2 * subjectBounds.height * (tether==TETHER_TOP?-1:1);
			}else{
				_perlinNoiseOffset[0].x += windSpeed*SPEED_MULTIPLIER_1 * subjectBounds.width * (tether==TETHER_LEFT?-1:1);
				_perlinNoiseOffset[1].x += windSpeed*SPEED_MULTIPLIER_2 * subjectBounds.height * (tether==TETHER_LEFT?-1:1);
			}
	
			//-- update perlinNoise
			_perlinNoiseBitmapData.perlinNoise( .66 * subjectBounds.width, .66 * subjectBounds.height, 2, _perlinNoiseSeed, false, true, 6, false, _perlinNoiseOffset );
			
			//-- reduce perlinNoise on the left side
			_perlinNoiseBitmapData.copyPixels( _gradientBitmapData, _gradientBitmapData.rect, ORIGIN, _gradientBitmapData, ORIGIN, true );
			
			//-- apply displacement
			_flagBitmapData.applyFilter( _subjectBitmapData, _flagBitmapData.rect, ORIGIN, _displacement );
			
			//-- copy displacement onto lights-bitmapData with alpha from current output
			_lightBitmapData.copyPixels( _perlinNoiseBitmapData, _perlinNoiseBitmapData.rect, ORIGIN, _flagBitmapData, ORIGIN );
			
			//-- turn perlinNoise into gray
			_lightBitmapData.applyFilter( _lightBitmapData, _lightBitmapData.rect, ORIGIN, GREY_FILTER );
	
			//-- draw onto output by blendMode MULTIPLY
			if(_shadows)_flagBitmapData.draw( _lightBitmapData, IDENTITY, _shadowContrast, BlendMode.MULTIPLY );
			
			if(_highlights)_flagBitmapData.draw( _lightBitmapData, IDENTITY, _highlightContrast, BlendMode.SCREEN );
			
			renderArea.bitmapData = _flagBitmapData;
			_flagBitmapData.unlock();
		}
		
		/**
		 * Creates the gradient to tether one side of the flag to the "pole"
		 */
		private function createGradientBitmap(width:Number, height:Number, angle:Number, offset:Point): BitmapData
		{
			var perlinNoiseFallOff:BitmapData = new BitmapData( width, height, true, 0 );
			var shape: Shape = new Shape();
			var gradientBox: Matrix = new Matrix();
			
			gradientBox.createGradientBox( width + offset.x, height, 0, -offset.x, angle );
			
			//-- draw gradient
			shape.graphics.beginGradientFill( 'linear', [ 0x008080, 0x008080 ], [ 99, 0 ], [ 0, 0x40 ], gradientBox );
			shape.graphics.drawRect(0,0,width,height);
			shape.graphics.endFill();
			
			//-- draw to bitmapData
			perlinNoiseFallOff.draw( shape );
			return perlinNoiseFallOff;
		}
	}
}