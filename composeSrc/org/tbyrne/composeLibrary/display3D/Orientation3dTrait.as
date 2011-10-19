package org.tbyrne.composeLibrary.display3D
{
	public class Orientation3dTrait extends AbsOrientation3dTrait
	{
		public function set posX(value:Number):void{
			setPosX(value);
		}
		public function set posY(value:Number):void{
			setPosY(value);
		}
		public function set posZ(value:Number):void{
			setPosZ(value);
		}
		public function set rotX(value:Number):void{
			setRotX(value);
		}
		public function set rotY(value:Number):void{
			setRotY(value);
		}
		public function set rotZ(value:Number):void{
			setRotZ(value);
		}
		public function Orientation3dTrait()
		{
			super();
		}
	}
}