package org.farmcode.sodalityPlatformEngine.physics.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.ISetPhysicsDebugAreaAdvice;
	
	import flash.display.Sprite;

	public class SetPhysicsDebugAreaAdvice extends Advice implements ISetPhysicsDebugAreaAdvice
	{
		private var _debugArea:Sprite;
		
		public function SetPhysicsDebugAreaAdvice(debugArea:Sprite=null, abortable:Boolean=true)
		{
			super(abortable);
			this.debugArea = debugArea;
		}
		
		[Property(toString="true",clonable="true")]
		public function set debugArea(value: Sprite): void
		{
			this._debugArea = value;
		}
		public function get debugArea(): Sprite
		{
			return this._debugArea;
		}
	}
}