package org.farmcode.sodalityPlatformEngine.particles.zones
{
	import org.flintparticles.threeD.geom.Vector3D;
	import org.flintparticles.threeD.zones.Zone3D;

	public class SceneEdgeZone implements Zone3D
	{
		private var _parent:ParallaxFrustrumZone;
		private var _edge:String;
		
		public function SceneEdgeZone(parent:ParallaxFrustrumZone, edge:String){
			_parent = parent;
			_edge = edge;
		}

		public function contains(p:Vector3D):Boolean{
			throw new Error("Not yet implemented");
			return false;
		}
		
		public function getLocation():Vector3D{
			return _parent.edgeGetLocation(_edge);
		}
		
		public function getVolume():Number{
			throw new Error("Not yet implemented");
			return 0;
		}
		
	}
}