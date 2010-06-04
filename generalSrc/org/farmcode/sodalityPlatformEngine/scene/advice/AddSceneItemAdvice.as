package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IAddSceneItemAdvice;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public class AddSceneItemAdvice extends AbstractSceneItemAdvice implements IAddSceneItemAdvice, IRevertableAdvice
	{
		private var _doRevert:Boolean = true;
		
		public function AddSceneItemAdvice(sceneItemPath:String=null, sceneItem:ISceneItem=null)
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
		public function get addToScene(): Boolean
		{
			return true;
		}
		
		public function get revertAdvice(): Advice
		{
			return new RemoveSceneItemAdvice(_sceneItemPath, sceneItem); 
		}
		
		override protected function _execute(cause:IAdvice, time:String):void{
			super._execute(cause, time);
		}
	}
}