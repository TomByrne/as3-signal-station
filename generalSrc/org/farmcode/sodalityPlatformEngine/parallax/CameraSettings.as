package org.farmcode.sodalityPlatformEngine.parallax
{
	import au.com.thefarmdigital.parallax.Point3D;

	public class CameraSettings extends Point3D
	{
		[Property(toString="true",clonable="true")]
		public var fieldOfView:Number=35;
		
		public function CameraSettings(x:Number=0, y:Number=0, z:Number=0, fieldOfView:Number=35){
			super(x, y, z);
			this.fieldOfView = fieldOfView;
		}
	}
}