package org.tbyrne.composeLibrary.away3d.traits
{
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.LightBase;
	
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.away3d.AbstractScene3dAwareTrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	
	public class GlobalLightTrait extends AbstractScene3dAwareTrait
	{
		public function get light():LightBase{
			return _light;
		}
		public function set light(value:LightBase):void{
			if(_light!=value){
				_light = value;
			}
		}
		
		private var _light:LightBase;
		
		
		public function GlobalLightTrait(){
			super();
		}
		
		override protected function unbindFromScene():void{
			_scene3d.removeGlobalLight(_light);
		}
		
		override protected function bindToScene():void{
			_scene3d.addGlobalLight(_light);
		}
	}
}