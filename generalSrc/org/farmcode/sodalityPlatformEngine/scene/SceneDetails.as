package org.farmcode.sodalityPlatformEngine.scene
{
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	
	public class SceneDetails
	{
		[Property(toString="true",clonable="true")]
		public var scene:IScene;
		[Property(toString="false",clonable="true")]
		public var scenePoints: Array;
		
		public function SceneDetails(){
		}
		
		public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}