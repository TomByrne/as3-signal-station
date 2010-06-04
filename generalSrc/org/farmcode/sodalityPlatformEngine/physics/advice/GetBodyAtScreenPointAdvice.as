package org.farmcode.sodalityPlatformEngine.physics.advice
{
	import Box2D.Dynamics.b2Body;
	
	import au.com.thefarmdigital.parallax.Point3D;
	
	import flash.geom.Point;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IConvertScreenPointAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IGetBodyAtPointAdvice;

	public class GetBodyAtScreenPointAdvice extends Advice implements IGetBodyAtPointAdvice, IConvertScreenPointAdvice
	{
		// IGetBodyAtPointAdvice implementation
		public function get worldPoint():Point{
			if(_position){
				return new Point(_position.x,_position.y);
			}
			return null;
		}
		[Property(toString="true",clonable="true")]
		public function get bodyAtPoint():b2Body{
			return _bodyAtMouse;
		}
		public function set bodyAtPoint(value:b2Body):void{
			_bodyAtMouse = value;
		}
		[Property(toString="true",clonable="true")]
		public function get includeStatic():Boolean{
			return _includeStatic;
		}
		public function set includeStatic(value:Boolean):void{
			_includeStatic = value;
		}
		
		private var _bodyAtMouse:b2Body;
		private var _includeStatic:Boolean;
		
		// IConvertScreenPointAdvice implementation
		[Property(toString="true",clonable="true")]
		public function set parallaxPoint(value:Point3D):void{
			_position = value;
		}
		public function get parallaxPoint():Point3D{
			return _position;
		}
		[Property(toString="true",clonable="true")]
		public function set screenPoint(value:Point):void{
			_screenPoint = value;
		}
		public function get screenPoint():Point{
			return _screenPoint;
		}
		[Property(toString="true",clonable="true")]
		public function set screenDepth(value:Number):void{
			_screenDepth = value;
		}
		public function get screenDepth():Number{
			return _screenDepth;
		}
		
		private var _position:Point3D;
		private var _screenPoint:Point;
		private var _screenDepth:Number;
		
		public function GetBodyAtScreenPointAdvice(includeStatic:Boolean=false)
		{
			this.includeStatic = includeStatic;
		}
		
	}
}