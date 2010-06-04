package org.farmcode.sodalityPlatformEngine.particles.zones
{
	import org.farmcode.sodalityPlatformEngine.particles.ParticleSceneEdges;
	
	import flash.geom.Rectangle;
	
	import org.flintparticles.threeD.geom.Vector3D;
	import org.flintparticles.threeD.zones.Zone3D;

	public class ParallaxFrustrumZone implements Zone3D
	{
		public var nearDistance:Number;
		public var nearRectangle:Rectangle;
		public var farDistance:Number;
		public var farRectangle:Rectangle;
		
		public function get topEdge():Zone3D{
			if(!_topEdge)_topEdge = new SceneEdgeZone(this,ParticleSceneEdges.TOP);
			return _topEdge;
		}
		public function get bottomEdge():Zone3D{
			if(!_bottomEdge)_bottomEdge = new SceneEdgeZone(this,ParticleSceneEdges.BOTTOM);
			return _bottomEdge;
		}
		public function get leftEdge():Zone3D{
			if(!_leftEdge)_leftEdge = new SceneEdgeZone(this,ParticleSceneEdges.LEFT);
			return _leftEdge;
		}
		public function get rightEdge():Zone3D{
			if(!_rightEdge)_rightEdge = new SceneEdgeZone(this,ParticleSceneEdges.RIGHT);
			return _rightEdge;
		}
		
		private var _topEdge:SceneEdgeZone;
		private var _leftEdge:SceneEdgeZone;
		private var _rightEdge:SceneEdgeZone;
		private var _bottomEdge:SceneEdgeZone;
		
		public function ParallaxFrustrumZone(nearDistance:Number=NaN, nearRectangle:Rectangle=null, farDistance:Number=NaN, farRectangle:Rectangle=null){
			this.nearDistance = nearDistance;
			this.nearRectangle = nearRectangle;
			this.farDistance = farDistance;
			this.farRectangle = farRectangle;
		}

		public function contains(p:Vector3D):Boolean{
			if(p.z<nearDistance || p.z>farDistance){
				return false;
			}
			var fract:Number = (p.z-nearDistance)/(farDistance-nearDistance);
			
			var sliceX:Number = nearRectangle.x+(farRectangle.x-nearRectangle.x)*fract;
			var sliceWidth:Number = nearRectangle.width+(farRectangle.width-nearRectangle.width)*fract;
			if(p.x<sliceX || p.x>sliceX+sliceWidth){
				return false;
			}
			
			var sliceY:Number = nearRectangle.y+(farRectangle.y-nearRectangle.y)*fract;
			var sliceHeight:Number = nearRectangle.height+(farRectangle.height-nearRectangle.height)*fract;
			if(p.y<sliceY || p.y>sliceY+sliceHeight){
				return false;
			}
			
			return true;
		}
		
		public function getLocation():Vector3D{
			return edgeGetLocation(null);
		}
		public function edgeGetLocation(edge:String):Vector3D{
			var fract:Number = Math.random();
			var z:Number = (fract*(farDistance-nearDistance))+nearDistance;
			
			var x:Number;
			var sliceX:Number = nearRectangle.x+(farRectangle.x-nearRectangle.x)*fract;
			var sliceWidth:Number = nearRectangle.width+(farRectangle.width-nearRectangle.width)*fract;
			if(edge==ParticleSceneEdges.LEFT){
				x = sliceX;
			}else if(edge==ParticleSceneEdges.RIGHT){
				x = sliceX+sliceWidth;
			}else{
				x = sliceX+Math.random()*sliceWidth;
			}
			
			var y:Number;
			var sliceY:Number = nearRectangle.y+(farRectangle.y-nearRectangle.y)*fract;
			var sliceHeight:Number = nearRectangle.height+(farRectangle.height-nearRectangle.height)*fract;
			if(edge==ParticleSceneEdges.TOP){
				y = sliceY;
			}else if(edge==ParticleSceneEdges.BOTTOM){
				y = sliceY+sliceHeight;
			}else{
				y = sliceY+Math.random()*sliceHeight;
			}
			return new Vector3D(x,y,z);
		}
		
		public function getVolume():Number{
			throw new Error("Not yet implemented");
			return 0;
		}
	}
}