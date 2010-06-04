package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;

	public class SceneRenderAdvice extends Advice implements ISceneRenderAdvice
	{
		protected var _scene: IScene;
		protected var _forceRender: Boolean;
		
		public function SceneRenderAdvice(scene: IScene = null)
		{
			super();
			
			this.scene = scene;
		}
		
		[Property(toString="true",clonable="true")]
		public function set scene(scene: IScene): void
		{
			this._scene = scene;
		}
		public function get scene(): IScene
		{
			return this._scene;
		}
		[Property(toString="true",clonable="true")]
		public function set forceRender(value: Boolean): void
		{
			this._forceRender = value;
		}
		public function get forceRender(): Boolean
		{
			return this._forceRender;
		}
	}
}