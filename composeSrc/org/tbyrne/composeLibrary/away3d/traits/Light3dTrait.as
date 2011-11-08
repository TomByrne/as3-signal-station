package org.tbyrne.composeLibrary.away3d.traits
{
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.LightBase;
	
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.away3d.types.ILight3dTrait;
	
	public class Light3dTrait extends AbstractTrait implements ILight3dTrait, IChild3dTrait
	{
		public function get light():LightBase{
			return _light;
		}
		public function set light(value:LightBase):void{
			if(_light!=value){
				_light = value;
			}
		}
		public function get object3d():ObjectContainer3D{
			return _light;
		}
		
		private var _light:LightBase;
		
		
		public function Light3dTrait(){
			super();
		}
	}
}