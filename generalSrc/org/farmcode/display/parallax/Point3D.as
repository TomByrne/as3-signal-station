package org.farmcode.display.parallax
{
	import org.farmcode.display.parallax.events.ParallaxEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.hoborg.ObjectPool;
	import org.farmcode.hoborg.ReadableObjectDescriber;

	[Event(name="positionChanged",type="org.farmcode.display.parallax.events.ParallaxEvent")]
	public class Point3D extends EventDispatcher implements IPoolable
	{
		private static const pool:ObjectPool = new ObjectPool(Point3D);
		public static function getNew(x:Number=0, y:Number=0, z:Number=0):Point3D{
			var ret:Point3D = pool.takeObject();
			ret.x = x;
			ret.y = y;
			ret.z = z;
			return ret;
		}
		
		[Property(clonable="true",toString="true")]
		public function set x(value:Number):void{
			if(_x != value){
				var oldX: Number = this.x;
				_x = value;
				this.dispatchChangeEvent(oldX, this.y, this.z);
			}
		}
		public function get x():Number{
			return _x;
		}
		
		[Property(clonable="true",toString="true")]
		public function set y(value:Number):void{
			if(_y != value){
				var oldY: Number = this.y;
				_y = value;
				this.dispatchChangeEvent(this.x, oldY, this.z);
			}
		}
		public function get y():Number{
			return _y;
		}
		
		[Property(clonable="true",toString="true")]
		public function set z(value:Number):void{
			if(_z != value){
				var oldZ: Number = this.z;
				_z = value;
				this.dispatchChangeEvent(this.x, this.y, oldZ);
			}
		}
		public function get z():Number{
			return _z;
		}
		
		private var _x:Number=0;
		private var _y:Number=0;
		private var _z:Number=0;
		
		public function Point3D(x:Number=0, y:Number=0, z:Number=0){
			this.x = x;
			this.y = y;
			this.z = z;
		}
		public function clone():Point3D{
			return Cloner.clone(this);
		}
		public function add(point:Point3D):void{
			if(!isNaN(point.x))x += point.x;
			if(!isNaN(point.y))y += point.y;
			if(!isNaN(point.z))z += point.z;
		}
		public function subtract(point:Point3D):void{
			if(!isNaN(point.x))x -= point.x;
			if(!isNaN(point.y))y -= point.y;
			if(!isNaN(point.z))z -= point.z;
		}
		
		private function dispatchChangeEvent(prevX: Number, prevY: Number, prevZ: Number): void
		{
			var event: ParallaxEvent = new ParallaxEvent(ParallaxEvent.POSITION_CHANGED);
			event.previousX = prevX;
			event.previousY = prevY;
			event.previousZ = prevZ;
			this.dispatchEvent(event);
		}
		
		public function toPoint():Point{
			return new Point(x,y);
		}
		override public function toString():String{
			return ReadableObjectDescriber.describe(this);
		}
		public function reset():void{
			_x=0;
			_y=0;
			_z=0;
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}