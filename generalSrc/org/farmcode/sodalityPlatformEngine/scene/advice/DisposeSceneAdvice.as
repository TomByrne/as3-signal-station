package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IReleaseObjectAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.SceneDetails;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IDisposeSceneAdvice;

	public class DisposeSceneAdvice extends Advice implements IDisposeSceneAdvice//, IReleaseObjectAdvice
	{
		private var _sceneDetails: SceneDetails;
		
		public function DisposeSceneAdvice(sceneDetails: SceneDetails = null, abortable:Boolean=true)
		{
			super(abortable);
			
			this.sceneDetails = sceneDetails;
		}
		
		[Property(toString="true",clonable="true")]
		public function set sceneDetails(value: SceneDetails): void
		{
			this._sceneDetails = value;
		}
		public function get sceneDetails(): SceneDetails
		{
			return this._sceneDetails;
		}
		public function get releaseObject(): Object
		{
			return this._sceneDetails.scene;
		}
	}
}