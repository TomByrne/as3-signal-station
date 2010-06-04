package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISetSceneItemEnabledAdvice;

	public class SetSceneItemEnabledAdvice extends AbstractSceneItemAdvice implements ISetSceneItemEnabledAdvice
	{
		private var _enabled: Boolean;
		
		public function SetSceneItemEnabledAdvice(enabled: Boolean = true, sceneItemPath:String=null, sceneItem:ISceneItem=null)
		{
			super(sceneItemPath, sceneItem);
			
			this.enabled = enabled;
		}
		
		[Property(clonable="true")]
		public function get enabled(): Boolean
		{
			return this._enabled;
		}
		public function set enabled(value: Boolean): void
		{
			this._enabled = value;
		}		
		
		public function get doRevert():Boolean
		{
			return true;
		}
		
		public function get revertAdvice():Advice
		{
			return new SetSceneItemEnabledAdvice(!this.enabled, _sceneItemPath, this.sceneItem);
		}
	}
}