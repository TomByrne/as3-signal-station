package org.farmcode.sodalityPlatformEngine.physics
{
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Common.Math.b2Vec2;
	
	public class PhysicsUtils
	{
		public static function scaleShape(shape:b2ShapeDef, scale:Number):b2ShapeDef{
			if(shape is b2CircleDef){
				var circle:b2CircleDef = (shape as b2CircleDef);
				var retCirc:b2CircleDef = new b2CircleDef();
				copyShape(circle,retCirc);
				retCirc.localPosition = new b2Vec2(circle.localPosition.x*scale,circle.localPosition.y*scale);
				retCirc.radius = circle.radius*scale;
				return retCirc;
			}else if(shape is b2PolygonDef){
				var polygon:b2PolygonDef = (shape as b2PolygonDef);
				var retPoly:b2PolygonDef = new b2PolygonDef();
				copyShape(polygon,retPoly);
				retPoly.vertexCount = polygon.vertexCount;
				retPoly.vertices = [];
				for(var i:int=0; i<polygon.vertexCount; ++i){
					var vertex:b2Vec2 = polygon.vertices[i];
					retPoly.vertices.push(new b2Vec2(vertex.x*scale,vertex.y*scale));
				}
				return retPoly;
			}
			return null;
		}
		private static function copyShape(from:b2ShapeDef, to:b2ShapeDef):void{
			to.density = from.density;
			to.filter = from.filter;
			to.friction = from.friction;
			to.isSensor = from.isSensor;
			to.restitution = from.restitution;
			to.type = from.type;
			to.userData = from.userData;
		}
	}
}