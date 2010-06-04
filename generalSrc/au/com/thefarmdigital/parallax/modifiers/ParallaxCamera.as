package au.com.thefarmdigital.parallax.modifiers
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	import au.com.thefarmdigital.parallax.Point3D;
	import au.com.thefarmdigital.parallax.events.ParallaxEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ParallaxCamera extends Point3D implements IParallaxModifier
	{
		private static var POSITION_ACCURACY:Number = 1/10;
		private static var SCALE_ACCURACY:Number = 1/100;
		
		private static function translate2Dto3D(point:Point, z:Number, fieldOfView:Number):Point3D{
			var ret:Point3D = Point3D.getNew();
			if(z){
				var scale:Number = Math.pow(Math.E,-z/fieldOfView);
				ret.x = point.x/scale;
				ret.y = point.y/scale;
				ret.z = scale;
			}else{
				ret.x = point.x;
				ret.y = point.y;
				ret.z = scale;
			}
			return ret;
		}
		private static function getItemPointAndScale(item:IParallaxDisplay, cameraPoint:Point3D, fieldOfView:Number):Point3D{
			var point3D:Point3D = item.position.clone();
			while(item.parallaxParent){
				item = item.parallaxParent;
				point3D.add(item.position);
			}
			return getPointAndScale(point3D, cameraPoint, fieldOfView);
		}
		private static function getPointAndScale(point3D:Point3D, cameraPoint:Point3D, fieldOfView:Number):Point3D{
			point3D.subtract(cameraPoint);
			if(fieldOfView){
				var scale:Number = Math.pow(Math.E,-point3D.z/fieldOfView)
				return Point3D.getNew(point3D.x*scale,point3D.y*scale,scale);
			}else{
				return Point3D.getNew(point3D.x,point3D.y,1);
			}
		}
		
		override public function set x(value:Number):void{
			if(super.x != value){
				super.x = value;
				dispatchEvent(new ParallaxEvent(ParallaxEvent.POSITION_CHANGED));
			}
		}
		override public function get x():Number{
			return super.x;
		}
		override public function set y(value:Number):void{
			if(super.y != value){
				super.y = value;
				dispatchEvent(new ParallaxEvent(ParallaxEvent.POSITION_CHANGED));
			}
		}
		override public function get y():Number{
			return super.y;
		}
		override public function set z(value:Number):void{
			if(super.z != value){
				super.z = value;
				dispatchEvent(new ParallaxEvent(ParallaxEvent.POSITION_CHANGED));
				dispatchEvent(new ParallaxEvent(ParallaxEvent.DEPTH_CHANGED));
			}
		}
		override public function get z():Number{
			return super.z;
		}
		public function set fieldOfView(value:Number):void{
			if(_fieldOfView!=value){
				_fieldOfView = value;
				dispatchEvent(new ParallaxEvent(ParallaxEvent.POSITION_CHANGED));
				dispatchEvent(new ParallaxEvent(ParallaxEvent.DEPTH_CHANGED));
			}
		}
		public function get fieldOfView():Number{
			return _fieldOfView;
		}
		public function get rounding():Boolean{
			return _rounding;
		}
		public function set rounding(value:Boolean):void{
			_rounding = value;
		}
		
		public function get screenRect():Rectangle{
			return _screenRect;
		}
		public function set screenRect(value:Rectangle):void{
			if(_screenRect!=value){
				_screenRect = value;
			}
		}
		
		private var _rounding:Boolean = false;
		private var _roundingOffset:Point;
		protected var _fieldOfView:Number=250;
		private var _screenRect:Rectangle;
		private var _positionAccuracy: Number;
		private var _scaleAccuracy: Number;
		
		public function ParallaxCamera()
		{
			this._positionAccuracy = ParallaxCamera.POSITION_ACCURACY;
			this._scaleAccuracy = ParallaxCamera.SCALE_ACCURACY;
		}
		public function inverseScale(depth:Number):Number{
			depth -= this.z;
			if(fieldOfView){
				var scale:Number = Math.pow(Math.E,-depth/fieldOfView)
				return 1/scale;
			}else{
				return 1;
			}
		}
		public function modifyContainer(container:DisplayObjectContainer):void{
			//trace("modifyContainer()");
			/*if (this._fieldOfView == 0)
			{
				trace("modifyContainer() -- [" + this.x + "x" + this.y + "] :: " + this._screenRect);
				trace(" container: " + container.localToGlobal(new Point()) + " [" + container.x + "x" + container.y + "] :: [" + container.parent.x + "x" + container.parent.y + "]");
				if (this._screenRect)
				{
					container.scrollRect = new Rectangle(this.x, this.y, this._screenRect.width, 
						this._screenRect.height);
				}
				//var halfW: Number = container.width / 2;
				//var halfH: Number = container.height / 2;
				//container.scrollRect = new Rectangle(this.x + halfW, this.y + halfH, container.width, 
				//	container.height);
				//container.x = -this.x;
				//container.y = -this.y; // TODO: this will have to be local to global?
			}
			else
			{
				container.scrollRect = null;
			}*/
			if(_rounding){
				var globalPoint:Point = container.localToGlobal(new Point());
				globalPoint.x = int(globalPoint.x);
				globalPoint.y = int(globalPoint.y);
				_roundingOffset = container.globalToLocal(globalPoint);
			}
		}
		public function getPointAndScale(point3D:Point3D):Point3D{
			return ParallaxCamera.getPointAndScale(point3D,this,fieldOfView);
		}
		public function translate2Dto3D(point:Point, z:Number):Point3D{
			return ParallaxCamera.translate2Dto3D(point,z,fieldOfView);
		}
		public function modifyItem(item:IParallaxDisplay, container:DisplayObjectContainer):void
		{
			if (_fieldOfView == 0)
			{
				var itemX: Number = item.position.x - this.x;
				var itemY: Number = item.position.y - this.y;
				
				if (this._rounding && this._roundingOffset)
				{
					itemX += _roundingOffset.x;
					itemY += _roundingOffset.y;
				}
				if (item.display.x != itemX)
				{
					item.display.x = itemX;
				}
				if (item.display.y != itemY)
				{
					item.display.y = itemY;
				}
				item.display.scaleX = 1;
				item.display.scaleY = 1;
				item.cameraDepth = item.position.z;
			}
			else
			{
				var point:Point3D = getItemPointAndScale(item,this,_fieldOfView);
				var display:DisplayObject = item.display;
				if(_rounding && _roundingOffset){
					point.x = (point.x-(point.x%1))+_roundingOffset.x;
					point.y = (point.y-(point.y%1))+_roundingOffset.y;
				}
				
				var diff:Number = Math.abs(display.x-point.x);
				if(diff>this._positionAccuracy){
					display.x = point.x;
				}
				
				diff = Math.abs(display.y-point.y);
				if(diff>this._positionAccuracy){
					display.y = point.y;
				}
				
				diff = Math.abs(Math.max(display.scaleX,display.scaleY)-point.z);
				if(diff>this._scaleAccuracy){
					display.scaleX = display.scaleY = point.z;
				}
				
				item.cameraDepth = item.position.z-this.z;
				point.release();
			}
		}
	}
}
