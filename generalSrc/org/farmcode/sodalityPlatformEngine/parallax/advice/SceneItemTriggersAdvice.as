package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	import org.farmcode.sodalityPlatformEngine.scene.advice.AbstractSceneItemAdvice;

	public class SceneItemTriggersAdvice extends AbstractSceneItemAdvice implements ISceneItemTriggersAdvice
	{
		private var _eventTriggers: Dictionary;
		private var _eventTargetProp: String;
		
		public function SceneItemTriggersAdvice(sceneItemId:String=null, sceneItem:ISceneItem=null,
			eventTriggers: Dictionary = null, eventTargetProp: String = null)
		{
			super(sceneItemId, sceneItem);
			
			this.eventTargetProp = eventTargetProp;
			this.eventTriggeredAdvice = eventTriggers;
		}
		
		[Property(toString="true",clonable="true")]
		public function get eventTargetProp(): String
		{
			return this._eventTargetProp;
		}
		public function set eventTargetProp(value: String): void
		{
			this._eventTargetProp = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get eventTriggeredAdvice(): Dictionary
		{
			return this._eventTriggers;
		}
		public function set eventTriggeredAdvice(value: Dictionary): void
		{
			this._eventTriggers = value;
		}
		
		public function get doRevert(): Boolean
		{
			return true;
		}
		
		public function get revertAdvice(): Advice
		{
			return null;
		}
	}
}