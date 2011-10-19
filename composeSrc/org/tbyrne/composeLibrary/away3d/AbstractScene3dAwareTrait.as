package org.tbyrne.composeLibrary.away3d
{
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.away3d.types.IScene3dAwareTrait;
	
	public class AbstractScene3dAwareTrait extends AbstractTrait implements IScene3dAwareTrait
	{
		
		public function get scene3d():IAway3dScene{
			return _scene3d;
		}
		public function set scene3d(value:IAway3dScene):void{
			if(_scene3d!=value){
				if(_scene3d)unbindFromScene();
				_scene3d = value;
				if(_scene3d)bindToScene();
			}
		}
		protected var _scene3d:IAway3dScene;
		
		public function AbstractScene3dAwareTrait()
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