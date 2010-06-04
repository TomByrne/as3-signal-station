package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import org.farmcode.sodalityPlatformEngine.scene.SceneDetails;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;
	
	public class ShowSceneAdvice extends SceneAdvice implements IShowSceneAdvice
	{
		public function ShowSceneAdvice(sceneDetailsPath:String=null,sceneDetails: SceneDetails=null){
			super(sceneDetailsPath, sceneDetails);
		}
		override public function get resolvePaths() : Array{
			var ret:Array = super.resolvePaths;
			if(_sceneDetailsPath)ret.push(_sceneDetailsPath+"/scene");
			return ret;
		}
	}
}