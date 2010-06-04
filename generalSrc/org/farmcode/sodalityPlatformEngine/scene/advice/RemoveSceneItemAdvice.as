package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IRemoveSceneItemAdvice;

	public class RemoveSceneItemAdvice extends AbstractSceneItemAdvice 
		implements IRemoveSceneItemAdvice, IRevertableAdvice
	{
		private var _doRevert:Boolean = true;
		
		public function RemoveSceneItemAdvice(sceneItemPath:String=null, sceneItem:ISceneItem=null)
		{
			super(sceneItemPath, sceneItem);
		}
		
		[Property(toString="true",clonable="true")]
		public function set doRevert(value: Boolean):void{
			_doRevert = value
		}
		public function get doRevert(): Boolean{
			return _doRevert;
		}
		
		public function get removeFromScene(): Boolean
		{
			return true;
		}
		
		public function get revertAdvice(): Advice
		{
			return new AddSceneItemAdvice(_sceneItemPath, sceneItem); 
		}
	}
}