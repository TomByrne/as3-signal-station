package org.farmcode.sodalityPlatformEngine.display.popUp.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes.IFocusOnSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;

	public class FocusOnSceneAdvice extends Advice implements IFocusOnSceneAdvice
	{
		[Property(toString="true", clonable="true")]
		public var focusValue: Object;
		
		private var _performFocus: Boolean;
		private var _scene: IScene;
		
		public function FocusOnSceneAdvice(focused: Boolean = true, scene: IScene = null)
		{
			super(true);
			
			this.focusValue = new Object();
			
			this.performFocus = true;
			this.focused = focused;
			this.scene = scene;
		}
		
		[Property(toString="true", clonable="true")]
		public function get scene(): IScene
		{
			return this._scene;
		}
		public function set scene(value: IScene): void
		{
			this._scene = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get performFocus(): Boolean
		{
			return this._performFocus;
		}
		public function set performFocus(value: Boolean): void
		{
			this._performFocus = value;
		}
		
		public function get focused(): Boolean
		{
			return this.focusValue["focused"];
		}
		public function set focused(value: Boolean): void
		{
			this.focusValue["focused"] = value;
		}
	}
}