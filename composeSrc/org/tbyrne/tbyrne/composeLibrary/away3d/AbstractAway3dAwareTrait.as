package org.tbyrne.tbyrne.composeLibrary.away3d
{
	import away3d.containers.Scene3D;
	
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	
	public class AbstractAway3dAwareTrait extends AbstractTrait implements IAway3dAwareTrait
	{
		
		public function get scene3d():Scene3D{
			return _scene3d;
		}
		public function set scene3d(value:Scene3D):void{
			if(_scene3d!=value){
				if(_scene3d)unbindFromScene();
				_scene3d = value;
				if(_scene3d)bindToScene();
			}
		}
		
		protected var _scene3d:Scene3D;
		
		public function AbstractAway3dAwareTrait()
		{
			super();
		}
		
		protected function unbindFromScene():void{
			// TODO Auto Generated method stub
			
		}
		
		protected function bindToScene():void{
			// TODO Auto Generated method stub
			
		}
	}
}